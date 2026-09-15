# Backend activation

The backend is implemented and tested. This guide prepares the first **staging**
release. No AWS/Atlas resources, public API, or owner accounts have been created
by adding these files.

## Configuration needed

Choose a dedicated Splash AWS account, Atlas project, region, and monthly budget.
Confirm the API hostname and the owners' email addresses privately. Keep database
passwords and connection strings out of issues, questionnaires, and client code.

Create a GitHub environment named `staging`. Its deployment branch rules must
allow only the reviewed release branch; configure its reviewer rules to match
who can authorize releases. These settings are not created by the workflow.

| Environment variable | Value to supply |
| --- | --- |
| `AWS_ROLE_ARN` | Dedicated role that GitHub may assume to push the Splash image |
| `AWS_REGION` | Selected AWS region, matching the ECR registry |
| `ECR_REGISTRY` | Private registry hostname, without `https://` or repository path |
| `ECR_REPOSITORY` | Existing dedicated Splash backend repository name |

The publishing workflow offers a target architecture. Select `linux/arm64` for
an ARM host or `linux/amd64` for an x86 host. This choice does not provision a host.

## AWS identity and repository

Create the dedicated ECR repository and GitHub OIDC role before running the
workflow. Allow ECR image-push operations only on that repository; registry login
also requires `ecr:GetAuthorizationToken`. The role does not need EC2 management,
SSH, database access, or permissions to create more repositories.

Use the actual GitHub OIDC subject for this repository and the `staging`
environment in the role's trust policy, with audience `sts.amazonaws.com`.
Do not assume the older subject format: newer repositories can include numeric
owner/repository IDs. GitHub environment branch restrictions control which refs
may use this environment-scoped identity. Follow the current
[GitHub OIDC configuration guidance](https://docs.github.com/en/actions/how-tos/secure-your-work/security-harden-deployments/oidc-in-aws)
and [AWS ECR push permissions](https://docs.aws.amazon.com/AmazonECR/latest/userguide/image-push-iam.html).

## Build and publish

The manual [Publish API image workflow](../.github/workflows/publish-api.yml)
validates configuration, runs backend tests against MongoDB, and publishes an
image tagged with its source commit. It records the immutable image digest in
the run summary. It does not replace a running server or publish either client.

GitHub requires a `workflow_dispatch` workflow to exist on the default branch
before it can be manually dispatched ([GitHub documentation](https://docs.github.com/en/actions/how-tos/manage-workflow-runs/manually-run-a-workflow)). While this PR remains unmerged, the file
is reviewable but is not an activated release pipeline.

After the workflow is reviewed, merged, and configured:

1. Open GitHub Actions, select **Publish API image**, and choose the reviewed ref.
2. Select the platform matching the intended host and run the workflow.
3. Confirm tests and image publishing succeeded.
4. Record the source commit, platform, and full `registry/repository@sha256:…`
   reference from the summary for the host deployment.

An image upload is not a live deployment. The workflow cannot finish until the
AWS role, ECR repository, and GitHub variables exist.

## Host and database

Use a Splash host with Docker and an instance role that can pull the dedicated
ECR image. Give the application a dedicated Atlas database user and restrict
Atlas network access to the API host's network. Configure backups and recovery
before using it for business operations.

Supply these values at runtime through a protected host environment file or
secret manager; do not bake them into the image:

| Runtime setting | Purpose |
| --- | --- |
| `MONGODB_URI` | Atlas TLS connection string, including the dedicated database credentials |
| `MONGODB_DATABASE` | Separate staging database, such as `splash_staging` |
| `ALLOWED_ORIGINS` | Comma-separated exact HTTPS origins for the website and Flutter app |

Protect an environment file so only the host administrator can read it. Run the
API on loopback behind HTTPS/WSS. The initial container command, after ECR login,
is:

```bash
# Set SPLASH_API_IMAGE to the immutable image reference from the workflow summary.
: "${SPLASH_API_IMAGE:?Set the image digest reference first}"
docker run -d --name splash-api --restart unless-stopped \
  --env-file /etc/splash/api.env \
  -p 127.0.0.1:8000:8000 \
  "$SPLASH_API_IMAGE"
curl --fail http://127.0.0.1:8000/health
```

This is the initial deployment command, not an update/rollback script. The
reverse proxy must support WebSocket upgrades, an idle timeout over 30 seconds,
and an 8 KiB request-body cap. Expose HTTPS to customers; do not expose MongoDB or
port 8000. Verify `/health` through the final HTTPS hostname as well.

For updates, retain the previous image digest and runtime configuration, verify
the new container's health, and restore the previous version if verification
fails. Future database migrations need their own compatibility/rollback plan;
the current release has no destructive data migration.

## Owners and clients

Enroll each owner separately from the trusted host using
`docker exec -it splash-api python manage_owner.py create OWNER_EMAIL`.
Replace `OWNER_EMAIL` with the real address. The command prompts privately for
the password. Both accounts have identical permissions.

Set `availability/config.js`'s `apiUrl` to the public HTTPS API origin. Build
Flutter using `--dart-define=SPLASH_API_URL=https://YOUR_API_HOST` with the actual
hostname. Repackage and publish the review site so both clients use the same
backend. Client configuration contains no database or AWS credentials.

Use the [English/Spanish owner guide](OWNER-WAIT-GUIDE.md) with both owners once
access is configured. Check, on their phones and a separate customer device:

- Each owner can sign in, publish, and sign out independently.
- An update appears on the website and Flutter without refreshing.
- Concurrent edits produce a reload prompt instead of silent overwrite.
- Expired or disconnected estimates show unavailable; wait means time until
  service **starts**, and the displayed note says it may change.
- English/Spanish and light/dark settings remain usable.

Keep staging separate from production data. Record the tested release before
connecting the production clients and real daily operations.
