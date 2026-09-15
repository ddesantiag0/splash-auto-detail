import os
import uuid
from datetime import timedelta
import mongomock
import pytest
from fastapi.testclient import TestClient
from pymongo import MongoClient
from main import create_app, digest, now, passwords

@pytest.fixture
def setup():
    client = MongoClient(os.environ['TEST_MONGODB_URI'], tz_aware=True) if os.getenv('TEST_MONGODB_URI') else mongomock.MongoClient(tz_aware=True)
    name = 'splash_test_' + uuid.uuid4().hex
    db = client[name]
    app = create_app(db, origins=['https://splash.test'])
    with TestClient(app) as http:
        for email in ['one@example.test', 'two@example.test']:
            db.owners.insert_one({'email': email, 'password_hash': passwords.hash('test-password-only'), 'active': True})
        yield http, db
    client.drop_database(name)
    client.close()

def login(http, email='one@example.test'):
    response = http.post('/v1/auth/login', json={'email': email, 'password': 'test-password-only'})
    assert response.status_code == 200
    token = response.json()['access_token']
    return token, {'Authorization': f'Bearer {token}'}

def change(version=1):
    return {'status': 'available', 'wait_min': 0, 'wait_max': 15, 'valid_minutes': 30, 'version': version}

def test_public_read_and_no_anonymous_updates(setup):
    http, db = setup
    result = http.get('/v1/wait')
    assert result.status_code == 200
    assert result.headers['cache-control'] == 'no-store'
    assert set(result.json()) == {'server_now', 'status'}
    assert 'password' not in result.text and 'email' not in result.text
    assert http.put('/v1/wait', json=change()).status_code == 401
    assert http.post('/v1/auth/signup', json={}).status_code == 404

def test_two_equal_owners_and_atomic_conflict(setup):
    http, db = setup
    _, first = login(http)
    _, second = login(http, 'two@example.test')
    result = http.put('/v1/wait', json=change(), headers=first)
    assert result.status_code == 200
    assert result.json()['version'] == 2
    assert http.put('/v1/wait', json=change(), headers=second).status_code == 409
    assert http.put('/v1/wait', json=change(2), headers=second).status_code == 200
    row = db.wait.find_one({'_id': 'shop'})
    assert row['expires_at'] - row['updated_at'] == timedelta(minutes=30)

@pytest.mark.parametrize('patch', [{'wait_max': -1}, {'wait_min': 20, 'wait_max': 10}, {'status': 'closed'}, {'valid_minutes': 1440}, {'updated_at': '2099-01-01'}, {'wait_min': True}, {'version': 0}])
def test_invalid_updates_rejected(setup, patch):
    http, _ = setup
    _, headers = login(http)
    assert http.put('/v1/wait', json={**change(), **patch}, headers=headers).status_code == 422

def test_sessions_hashed_expired_revoked_and_logout(setup):
    http, db = setup
    token, headers = login(http)
    assert db.sessions.find_one({'_id': digest(token)})
    assert not db.sessions.find_one({'_id': token})
    db.sessions.update_one({'_id': digest(token)}, {'$set': {'expires_at': now() - timedelta(seconds=1)}})
    assert http.get('/v1/auth/me', headers=headers).status_code == 401
    _, headers = login(http)
    db.owners.update_one({'email': 'one@example.test'}, {'$set': {'active': False}})
    assert http.put('/v1/wait', json=change(), headers=headers).status_code == 401
    _, headers = login(http, 'two@example.test')
    assert http.post('/v1/auth/logout', headers=headers).status_code == 200
    assert http.get('/v1/auth/me', headers=headers).status_code == 401

def test_login_throttling_and_generic_errors(setup):
    http, _ = setup
    for _ in range(10):
        assert http.post('/v1/auth/login', json={'email': 'missing@example.test', 'password': 'bad'}).status_code == 401
    assert http.post('/v1/auth/login', json={'email': 'missing@example.test', 'password': 'bad'}).status_code == 429

def test_stream_reflects_owner_update_without_refresh(setup):
    http, _ = setup
    _, headers = login(http)
    with http.websocket_connect('/v1/wait/stream', headers={'origin': 'https://splash.test'}) as ws:
        assert ws.receive_json()['status']['version'] == 1
        assert http.put('/v1/wait', json=change(), headers=headers).status_code == 200
        assert ws.receive_json()['status']['version'] == 2

def test_cors_and_websocket_origin(setup):
    http, _ = setup
    assert 'access-control-allow-origin' not in http.get('/v1/wait', headers={'origin': 'https://evil.test'}).headers
    from starlette.websockets import WebSocketDisconnect
    with pytest.raises(WebSocketDisconnect):
        with http.websocket_connect('/v1/wait/stream', headers={'origin': 'https://evil.test'}):
            pass
