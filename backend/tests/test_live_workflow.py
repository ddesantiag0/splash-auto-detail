"""Real HTTP/WebSocket workflow; requires an explicitly supplied test MongoDB."""
import json
import os
import socket
import subprocess
import sys
import time
import uuid
from concurrent.futures import ThreadPoolExecutor
from contextlib import contextmanager
from datetime import datetime, timedelta, timezone
from pathlib import Path
from threading import Barrier

import httpx
import pytest
from pymongo import MongoClient
from websockets.sync.client import connect

from main import digest, passwords

pytestmark = pytest.mark.skipif(
    not os.getenv('TEST_MONGODB_URI'), reason='Requires a disposable real MongoDB instance'
)
BACKEND = Path(__file__).resolve().parents[1]
ORIGIN = 'https://splash.test'


@contextmanager
def running_api(database, log_path):
    # Pass a bound socket to Uvicorn to avoid racing for a free port.
    with socket.socket() as listener, log_path.open('w+') as log:
        listener.bind(('127.0.0.1', 0))
        listener.listen(128)
        port = listener.getsockname()[1]
        env = {**os.environ, 'MONGODB_URI': os.environ['TEST_MONGODB_URI'],
               'MONGODB_DATABASE': database, 'ALLOWED_ORIGINS': ORIGIN}
        process = subprocess.Popen(
            [sys.executable, '-m', 'uvicorn', 'main:app', '--fd', str(listener.fileno()),
             '--no-proxy-headers'], cwd=BACKEND, env=env,
            pass_fds=(listener.fileno(),), stdout=log, stderr=log,
        )
        try:
            with httpx.Client(base_url=f'http://127.0.0.1:{port}', timeout=5) as http:
                deadline = time.monotonic() + 20
                while time.monotonic() < deadline:
                    if process.poll() is not None:
                        pytest.fail('API failed to start: ' + log_path.read_text())
                    try:
                        if http.get('/health').status_code == 200:
                            break
                    except httpx.HTTPError:
                        pass
                    time.sleep(0.1)
                else:
                    pytest.fail('API readiness timed out: ' + log_path.read_text())
                yield http, f'ws://127.0.0.1:{port}/v1/wait/stream'
        finally:
            process.terminate()
            try:
                process.wait(timeout=10)
            except subprocess.TimeoutExpired:
                process.kill()
                process.wait(timeout=5)


def receive_until(ws, predicate):
    deadline = time.monotonic() + 8
    while time.monotonic() < deadline:
        event = json.loads(ws.recv(timeout=max(0.1, deadline - time.monotonic())))
        if predicate(event):
            return event
    pytest.fail('Live customer update did not arrive')


def test_two_owners_live_updates_restart_logout_and_expiry(tmp_path):
    name = 'splash_test_live_' + uuid.uuid4().hex
    client = MongoClient(os.environ['TEST_MONGODB_URI'], tz_aware=True,
                         serverSelectionTimeoutMS=5000)
    db = client[name]
    try:
        for email in ['one@example.test', 'two@example.test']:
            db.owners.insert_one({'email': email, 'password_hash': passwords.hash('test-password-only'), 'active': True})
        with running_api(name, tmp_path / 'first.log') as (first, stream_url):
            with running_api(name, tmp_path / 'second.log') as (second, _):
                headers = []
                for http, email in [(first, 'one@example.test'), (second, 'two@example.test')]:
                    result = http.post('/v1/auth/login', json={'email': email, 'password': 'test-password-only'})
                    assert result.status_code == 200
                    headers.append({'Authorization': 'Bearer ' + result.json()['access_token']})
                with connect(stream_url, origin=ORIGIN, open_timeout=5) as ws:
                    initial = json.loads(ws.recv(timeout=5))
                    assert initial['status']['version'] == 1
                    barrier = Barrier(2)

                    def save(http, auth, status):
                        barrier.wait(timeout=5)
                        return http.put('/v1/wait', headers=auth, json={
                            'status': status, 'wait_min': 15, 'wait_max': 30,
                            'valid_minutes': 30, 'version': 1})

                    with ThreadPoolExecutor(max_workers=2) as pool:
                        jobs = [pool.submit(save, first, headers[0], 'available'),
                                pool.submit(save, second, headers[1], 'busy')]
                        results = [job.result(timeout=10) for job in jobs]
                    assert sorted(result.status_code for result in results) == [200, 409]
                    saved = next(result.json() for result in results if result.status_code == 200)
                    assert receive_until(ws, lambda event: event['status']['version'] == 2)['status'] == saved
                    assert second.get('/v1/wait').json()['status'] == saved
                    # The other owner reloads and can save equally, through another process.
                    loser = 0 if results[0].status_code == 409 else 1
                    result = second.put('/v1/wait', headers=headers[loser], json={
                        'status': 'closed', 'wait_min': None, 'wait_max': None,
                        'valid_minutes': 15, 'version': 2})
                    assert result.status_code == 200
                    persisted = result.json()
                    assert receive_until(ws, lambda event: event['status']['version'] == 3)['status'] == persisted
        # Both API processes have stopped; MongoDB retains status and sessions.
        with running_api(name, tmp_path / 'restarted.log') as (http, stream_url):
            assert http.get('/v1/wait').json()['status'] == persisted
            assert http.get('/v1/auth/me', headers=headers[0]).status_code == 200
            assert http.post('/v1/auth/logout', headers=headers[0]).status_code == 200
            assert http.get('/v1/auth/me', headers=headers[0]).status_code == 401
            assert http.get('/v1/auth/me', headers=headers[1]).status_code == 200
            token = headers[1]['Authorization'].removeprefix('Bearer ')
            db.sessions.update_one({'_id': digest(token)}, {'$set': {
                'expires_at': datetime.now(timezone.utc) - timedelta(seconds=1)}})
            assert http.get('/v1/auth/me', headers=headers[1]).status_code == 401
            # Controlled clock fixture avoids waiting 15 minutes; expiry must reach
            # customer snapshots unchanged so clients can show the unknown state.
            expired = datetime.now(timezone.utc) - timedelta(seconds=1)
            db.wait.update_one({'_id': 'shop'}, {'$set': {'expires_at': expired}})
            with connect(stream_url, origin=ORIGIN, open_timeout=5) as ws:
                event = json.loads(ws.recv(timeout=5))
                assert datetime.fromisoformat(event['status']['expires_at']) < datetime.fromisoformat(event['server_now'])
                assert event['status'] == http.get('/v1/wait').json()['status']
    finally:
        client.drop_database(name)
        client.close()
