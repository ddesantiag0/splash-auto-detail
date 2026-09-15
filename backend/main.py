import asyncio
import hashlib
import os
import secrets
from contextlib import asynccontextmanager
from datetime import datetime, timedelta, timezone
from typing import Literal
from fastapi import Depends, FastAPI, HTTPException, Request, WebSocket, WebSocketDisconnect
from fastapi.encoders import jsonable_encoder
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from pydantic import BaseModel, ConfigDict, Field, model_validator
from pwdlib import PasswordHash
from pymongo import MongoClient, ReturnDocument
from pymongo.errors import PyMongoError
from starlette.concurrency import run_in_threadpool

passwords = PasswordHash.recommended()
DUMMY_HASH = passwords.hash('not-an-owner-password')
bearer = HTTPBearer(auto_error=False)
PUBLIC_FIELDS = ('status', 'wait_min', 'wait_max', 'valid_minutes', 'updated_at', 'expires_at', 'version')

def now():
    return datetime.now(timezone.utc)

def digest(value):
    return hashlib.sha256(value.encode()).hexdigest()

def prepare(db):
    db.owners.create_index('email', unique=True)
    db.sessions.create_index('expires_at', expireAfterSeconds=0)
    db.login_limits.create_index('expires_at', expireAfterSeconds=0)
    db.wait.update_one({'_id': 'shop'}, {'$setOnInsert': {
        'status': 'closed', 'wait_min': None, 'wait_max': None, 'valid_minutes': 30,
        'updated_at': now(), 'expires_at': now(), 'version': 1}}, upsert=True)

def snapshot(db):
    row = db.wait.find_one({'_id': 'shop'})
    return {'server_now': now(), 'status': {k: row[k] for k in PUBLIC_FIELDS} if row else None}

class Login(BaseModel):
    model_config = ConfigDict(extra='forbid')
    email: str = Field(min_length=3, max_length=254)
    password: str = Field(min_length=1, max_length=1024)

class WaitUpdate(BaseModel):
    model_config = ConfigDict(extra='forbid', strict=True)
    status: Literal['available', 'moderate', 'busy', 'closed']
    wait_min: int | None = Field(default=None, ge=0, le=240)
    wait_max: int | None = Field(default=None, ge=0, le=240)
    valid_minutes: Literal[15, 30, 60]
    version: int = Field(ge=1)

    @model_validator(mode='after')
    def check_range(self):
        if self.status == 'closed':
            if self.wait_min is not None or self.wait_max is not None:
                raise ValueError('Closed status must not have an estimate')
        elif self.wait_min is None or self.wait_max is None or self.wait_max < self.wait_min:
            raise ValueError('Choose a valid wait range')
        return self

def create_app(database=None, origins=None):
    allowed = origins if origins is not None else [s.strip() for s in os.getenv('ALLOWED_ORIGINS', '').split(',') if s.strip()]
    if '*' in allowed:
        raise ValueError('Use explicit allowed origins')

    @asynccontextmanager
    async def lifespan(app):
        client = None
        if database is None:
            client = MongoClient(os.environ['MONGODB_URI'], tz_aware=True, serverSelectionTimeoutMS=5000)
            app.state.db = client[os.getenv('MONGODB_DATABASE', 'splash')]
        else:
            app.state.db = database
        await run_in_threadpool(prepare, app.state.db)
        yield
        if client is not None:
            client.close()

    app = FastAPI(title='Splash Auto API', version='1.0.0', lifespan=lifespan)
    app.add_middleware(CORSMiddleware, allow_origins=allowed, allow_methods=['GET', 'POST', 'PUT'], allow_headers=['Authorization', 'Content-Type'])

    @app.middleware('http')
    async def headers(request, call_next):
        response = await call_next(request)
        response.headers['Cache-Control'] = 'no-store'
        response.headers['X-Content-Type-Options'] = 'nosniff'
        return response

    @app.exception_handler(PyMongoError)
    async def unavailable(request, error):
        return JSONResponse({'detail': 'Service temporarily unavailable'}, status_code=503)

    def owner(request: Request, credentials: HTTPAuthorizationCredentials | None = Depends(bearer)):
        if credentials is None or len(credentials.credentials) > 256:
            raise HTTPException(401, 'Sign in required')
        db = request.app.state.db
        session = db.sessions.find_one({'_id': digest(credentials.credentials), 'expires_at': {'$gt': now()}})
        account = db.owners.find_one({'_id': session['owner_id'], 'active': True}) if session else None
        if not account:
            raise HTTPException(401, 'Sign in required')
        return account

    @app.get('/health')
    def health(request: Request):
        request.app.state.db.command('ping')
        return {'status': 'ok'}

    @app.get('/v1/wait')
    def read_wait(request: Request):
        return snapshot(request.app.state.db)

    @app.post('/v1/auth/login')
    def login(body: Login, request: Request):
        db = request.app.state.db
        email = body.email.strip().casefold()
        bucket = int(now().timestamp()) // 900
        # Shared counters across API workers; don't trust client forwarded headers.
        for scope, value, limit in [('email', email, 10), ('ip', request.client.host if request.client else 'unknown', 50)]:
            key = digest(f'{scope}:{value}:{bucket}')
            counter = db.login_limits.find_one_and_update({'_id': key}, {'$inc': {'count': 1}, '$setOnInsert': {'expires_at': now() + timedelta(minutes=30)}}, upsert=True, return_document=ReturnDocument.AFTER)
            if counter['count'] > limit:
                raise HTTPException(429, 'Too many attempts. Try again later.', headers={'Retry-After': '900'})
        account = db.owners.find_one({'email': email})
        valid = passwords.verify(body.password, account['password_hash'] if account else DUMMY_HASH)
        if not valid or not account or not account.get('active'):
            raise HTTPException(401, 'Invalid email or password')
        token = secrets.token_urlsafe(32)
        expires = now() + timedelta(hours=12)
        db.sessions.insert_one({'_id': digest(token), 'owner_id': account['_id'], 'expires_at': expires})
        return {'access_token': token, 'token_type': 'bearer', 'expires_at': expires}

    @app.get('/v1/auth/me')
    def me(account=Depends(owner)):
        return {'owner': True}

    @app.post('/v1/auth/logout')
    def logout(request: Request, credentials: HTTPAuthorizationCredentials | None = Depends(bearer)):
        if credentials and len(credentials.credentials) <= 256:
            request.app.state.db.sessions.delete_one({'_id': digest(credentials.credentials)})
        return {'signed_out': True}

    @app.put('/v1/wait')
    def update_wait(body: WaitUpdate, request: Request, account=Depends(owner)):
        timestamp = now()
        values = body.model_dump(exclude={'version'})
        values.update(updated_at=timestamp, expires_at=timestamp + timedelta(minutes=body.valid_minutes))
        row = request.app.state.db.wait.find_one_and_update({'_id': 'shop', 'version': body.version}, {'$set': values, '$inc': {'version': 1}}, return_document=ReturnDocument.AFTER)
        if not row:
            raise HTTPException(409, 'Status changed. Reload before saving.')
        return {k: row[k] for k in PUBLIC_FIELDS}

    @app.websocket('/v1/wait/stream')
    async def stream(socket: WebSocket):
        origin = socket.headers.get('origin')
        if origin and origin not in allowed:
            await socket.close(code=1008)
            return
        await socket.accept()
        try:
            while True:
                data = await run_in_threadpool(snapshot, socket.app.state.db)
                await socket.send_json(jsonable_encoder(data))
                try:
                    await asyncio.wait_for(socket.receive_text(), timeout=2)
                    await socket.close(code=1008)
                    return
                except asyncio.TimeoutError:
                    pass
        except WebSocketDisconnect:
            pass
        except PyMongoError:
            await socket.close(code=1011)
    return app

app = create_app()
