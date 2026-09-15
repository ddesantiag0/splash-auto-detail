# Splash FastAPI backend

Independent Splash service using Python/FastAPI, PyMongo, MongoDB (Atlas in production), and Docker. No ooLEO source, data, accounts, or credentials are used.

## Local development

From this directory:

```bash
docker compose up --build -d
docker compose exec api python manage_owner.py create owner@example.com
```

Replace the example address with an owner's actual email. The command prompts privately for a password; use a unique password for each owner. Repeat for the second owner. The local Mongo service is reachable only inside Docker's network, and the API binds only to localhost. This compose file is not a production deployment.

Set `apiUrl` in `../availability/config.js` to `http://localhost:8000`, serve the website on port 5500, and run Flutter from `app/`:

```bash
flutter run -d chrome --web-port 8080 --dart-define=SPLASH_API_URL=http://localhost:8000
```

Open Owner controls in the app or bookmark `/app/#/owner` in the hosted review build. Test on localhost unless you have an HTTPS development endpoint.

## API contract

| Route | Access | Purpose |
| --- | --- | --- |
| GET /health | Public | Database readiness |
| GET /v1/wait | Public | Status and server time |
| WS /v1/wait/stream | Public; allowed browser origins | Snapshot/heartbeat every two seconds |
| POST /v1/auth/login | Rate-limited | Email/password to opaque bearer session |
| GET /v1/auth/me | Active owner session | Verify current permission |
| POST /v1/auth/logout | Current bearer token | Revoke session |
| PUT /v1/wait | Active owner session | Validated update with expected version |

Example update body: `{"status":"available","wait_min":0,"wait_max":15,"valid_minutes":30,"version":1}`. Closed requires null wait values. Conflicts return 409; invalid data 422; invalid/revoked sessions 401; throttled sign-in 429. Public responses contain only status, wait range, freshness settings, timestamps and version.

## Authentication and storage

Owner accounts are enrolled only from the trusted backend host, never via public signup. Argon2 hashes protect passwords. Random 256-bit session tokens are returned once; only SHA-256 token hashes are stored. Sessions last 12 hours. Expiry is checked on every request, independently of MongoDB TTL cleanup. Disabled owners are blocked immediately. Both owners have identical permissions. Password resets revoke prior sessions.

Flutter holds the bearer token in memory: it stays signed in while the app runs, and requires sign-in after a full reload/restart. Use the device's password manager. Persistent secure device storage and self-service recovery are future enhancements, not silently simulated features.

```bash
docker compose exec api python manage_owner.py reset-password owner@example.com
docker compose exec api python manage_owner.py disable owner@example.com
```

Snapshots start expired; no fake green status is seeded. Updates set server timestamps and atomically increment the version. Public WebSockets read shared MongoDB snapshots, so multiple API workers see the same updates without a replica-set change-stream requirement. This simple first version polls MongoDB per connection every two seconds; scale to a shared broadcaster before high traffic.

## Production: Atlas + EC2 + ECR

Provision dedicated Splash resources after AWS account, Atlas project, region, budget and owner identities are confirmed. The Docker image supports the EC2/ECR approach used at ooLEO, but nothing has been provisioned or deployed there yet.

1. Create the Atlas database and least-privilege application user for the `splash` database. Allow only the API host's egress IP/private network. Use the Atlas TLS connection string.
2. Build and push `backend/` to a dedicated ECR repository, using GitHub OIDC for image-push permission. For an ARM EC2 instance build `linux/arm64`; do not deploy an x86-only image.
3. Give EC2 an instance role for ECR pull and secret retrieval. Keep `MONGODB_URI` in AWS Secrets Manager or a protected host environment file, never GitHub source, build arguments, or browser code. Set `MONGODB_DATABASE=splash` and explicit comma-separated `ALLOWED_ORIGINS` for the website and Flutter hosts.
4. Run the API container on loopback behind an HTTPS reverse proxy or load balancer. Forward WebSocket upgrades, use idle timeout >30 seconds, cap request bodies (8 KiB is sufficient), and apply connection/rate limits at the edge. Expose only HTTPS, not MongoDB or port 8000. Uvicorn does not trust forwarded client addresses; its per-IP login limit groups requests behind a proxy, while the per-email limit remains independent.
5. Enroll the owners on the trusted host. Set the public `apiUrl` and Flutter `SPLASH_API_URL` to the HTTPS API origin; rebuild and publish the review clients. The current CI deliberately has no cloud credentials and does not deploy automatically.
6. Verify health, HTTPS/WSS, allowed origins, both accounts, logout/revocation, status expiry, conflict handling, and a customer screen updating from another device. Enable Atlas backups/monitoring and establish credential recovery before business launch.

## Tests

```bash
python -m venv .venv
.venv/bin/pip install -r requirements-dev.txt
PYTHONPATH=. .venv/bin/pytest tests -q
```

Local tests default to mongomock. Set `TEST_MONGODB_URI` to a disposable Mongo instance to test actual database behavior. CI uses MongoDB 8 and builds the Docker image. Test databases have random names and are deleted after tests. Never point tests at a business database account.
