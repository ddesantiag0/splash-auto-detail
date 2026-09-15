# Splash development workflow

## Purpose and scope

Use a clear client/API/database boundary, small tracked changes, automated
checks, and a repeatable release process. These are the useful delivery patterns
from David's ooLEO experience. Splash remains an independent product for one
family shop, with its own code, infrastructure, data, and accounts.

Here, **organization** means how the project and development work are organized.
It does not introduce organizations, tenants, subscriptions, or company onboarding
into the application. If organization management is wanted as a product feature,
record its purpose and obtain a separate product decision before implementing it.

## Evidence and limits

This plan distinguishes three sources:

- **Verified in this repository:** the paths, checks, API boundaries, and current
  behavior listed below. See [architecture](../ARCHITECTURE.md),
  [CI](../.github/workflows/ci.yml), [backend guide](../backend/README.md), and
  [wait integration](../availability/README.md).
- **Prior project context supplied by David:** the internship application uses
  Flutter, FastAPI, MongoDB Atlas, and Docker, with an AWS EC2/ECR delivery approach
  and ticket-based work. That context motivates the delivery pattern; it is not
  evidence that Splash cloud resources or deployment automation already exist.
- **Proposed Splash workflow:** the board, release gates, and next tasks below.
  This document does not create a project board, change branch protections, deploy
  a service, or grant anyone access.

An accessible ooLEO marketing README describes a separate Next.js prototype,
not the internship application's implementation. It was not used as a source for
Flutter/FastAPI implementation details. No internship source, private business
documents, infrastructure identifiers, or credentials are copied into this repo.

## Repository responsibilities

| Area | Existing location | Responsibility |
| --- | --- | --- |
| Public website | Root HTML, CSS, JavaScript | Searchable business content, contact, directions, public wait display |
| Flutter application | `app/lib/` | Customer interface and owner controls |
| Shared Flutter foundations | `app/lib/core/` | Theme, localization, responsive components |
| Feature code | `app/lib/features/` | Home, appointment drafts, account placeholder, shop availability |
| Backend | `backend/main.py` | Owner authentication, validated wait updates, public reads and streams |
| Owner enrollment | `backend/manage_owner.py` | Trusted-host account creation, reset, and disable operations |
| Database | MongoDB; local Compose service | Owner records, sessions, rate limits, one shop status |
| Website API client | `availability/` | Public API configuration, status rules, source and generated bundle |
| Translations | `localization/` and `scripts/generate-localization.py` | Source translations and generated website/Flutter output |
| Verification | `test/`, `app/test/`, `backend/tests/` | Website, Flutter, API, and live network regression checks |
| Review packaging | `scripts/package-review.py` | Assemble website and Flutter web build for review |
| Product decisions | Owner questionnaires | Both owners' answers, unresolved choices, optional ideas |

Keep this structure while the backend is small. Split it into routers, services,
and database modules when an approved second backend feature makes those
boundaries useful. A directory reshuffle alone is not a product milestone.

## Business and access model

- Both owners have equal authority and review business decisions together.
- Each owner receives a separate login with the same shop-wait permissions.
- There is one shared shop status. No owner automatically overrides the other;
  version conflicts require reloading the latest state before another update.
- Customers can read the shop wait without an account. Public responses contain
  no owner credentials or customer records.
- Estimated minutes mean **time until service starts**, and may change. An
  expired or unavailable estimate must not be presented as a current promise.
- Regular services remain first come, first served. Wax and polishing appointment
  requests are separate from shop wait; their existing form only creates a draft.

The approved shop-wait feature does not approve individual vehicle tracking,
payments, customer accounts, messaging, or automatic appointment confirmation.

## Track work from decision to release

Use a small board with **Backlog → Ready → In progress → Review → Done**. Add a
**Blocked** state when a task needs a concrete dependency such as the API host or
an owner's answer. This is a proposed board structure, not a configured GitHub
Project or Jira board.

Each task should record:

- The observed problem or approved requirement.
- The affected surface: website, Flutter, API, content, or infrastructure.
- Acceptance criteria that describe observable results.
- Relevant owner decision and any unresolved dependency.
- The responsible contributor, branch/PR, and verification evidence.

Use separate completion criteria for implementation and activation. A tested
feature can be **code complete** while its release task remains **blocked** on
hosting. Never label an unconfigured customer experience as live.

For parallel work, assign separate files or feature boundaries before editing.
Integrate changes together, check for interactions, and preserve direct edits to
the owner questionnaires. Commit attribution remains David De Santiago's; do not
add generated-by or co-author trailers.

## Branch and review flow

The current foundation is on `david/flutter-app-foundation` in PR #2. Keep that PR
reviewable and preserve its unmerged state until the release decision is made.
For subsequent tasks, use focused `david/<task>` branches from the agreed base.

1. Read the current code and decision record before changing behavior.
2. Implement one bounded task and its meaningful regression coverage.
3. Run the relevant local checks; report unavailable tools honestly.
4. Open or update the PR with the problem, changed behavior, tests, and limits.
5. Require the relevant CI jobs to pass before merging the reviewed change.
6. Review the configured preview, then release and verify the deployed result.

The [pull request template](../.github/pull_request_template.md) captures the
problem, changes, verification, and release impact for this flow.

A separate `develop` branch and automatic development deployment may be useful
once Splash has a maintained staging environment. They are not needed merely to
match another project's branch names. Current CI runs on pull requests and pushes
to `main`; it tests and packages builds, but does not deploy the API.

## Verification gates

| Gate | Existing automation | Additional release evidence |
| --- | --- | --- |
| Website | Bundle rebuild consistency and Node tests | Mobile navigation, logo contrast, language/theme behavior, directions |
| Flutter | Analysis, tests, release web build | Owner controls on both owners' actual phones; customer view on another device |
| Backend | API tests against MongoDB and live Uvicorn workflow tests | Configured HTTPS/WSS endpoint, explicit origins, real owner enrollment |
| Container | Docker image build | Image architecture matches host; deployed image identity recorded |
| Business content | Owner questionnaires | Both owners confirm facts; authorized photos replace placeholders |

CI checks do not establish production readiness by themselves. In particular,
synthetic owner tests do not demonstrate that either owner's phone can reach a
deployed API. The [backend guide](../backend/README.md) contains local commands
and the real-database workflow test instructions.

## Environments and deployment

| Environment | Intended use | Current boundary |
| --- | --- | --- |
| Local | Development and disposable test data | Compose configuration exists; tools must be installed locally |
| Review/staging | Owners inspect the next release | Review packaging exists; live wait needs its configured API |
| Production | Customers and daily shop operations | Dedicated Splash hosting and operational verification still required |

Use dedicated Splash Atlas and AWS resources. Before provisioning, confirm the
business-controlled accounts, region, budget, domain/API origin, and owner email
addresses. Do not reuse internship accounts or credentials.

The deployment task should build a versioned backend image, push it to Splash's
ECR repository, and run it on the selected host with secrets supplied at runtime.
GitHub OIDC and an instance role avoid storing long-lived AWS access keys in the
repository. Exact resources and permissions belong in the deployment task once
the target accounts are available; no deploy workflow is active today.

Record the released commit and image digest. Before launch, establish a previous
working image to roll back to, database backup/recovery steps, health monitoring,
and a person responsible for operational issues. Test a customer update across
devices, a conflicting owner edit, logout, and estimate expiry on the configured
review environment before the production rollout.

## Next tasks

| Priority | Task | Completion criteria | Dependency |
| --- | --- | --- | --- |
| 1 | Owner-screen usability | Both owners can sign in, update a range, recover from a conflict, and sign out on their phones | Configured review API and separate owner accounts |
| 1 | Backend activation | Dedicated resources, HTTPS/WSS, explicit origins, health checks, and deployed version recorded | Splash account access, budget, domain, owner emails |
| 1 | End-to-end review | Website and Flutter show the same update and handle expiry/disconnection accurately | Backend activation and rebuilt clients |
| 2 | Owner operating guide | Short English/Spanish steps for updating, expiry, conflicts, and access recovery | Stable reviewed owner flow |
| 2 | Content completion | Owner answers reconciled; authorized photos and accurate captions added | Both owners' responses and photo folder |
| 2 | Release controls | Agreed merge checks, deployment trigger, rollback steps, and monitoring verified | Hosting setup and reviewed release process |
| Later | Appointment backend | Written acceptance criteria agreed before implementation | Confirmed intake and confirmation rules |

Individual vehicle progress tracking and other questionnaire ideas stay in the
ideas backlog unless both owners approve them. Organization/tenant onboarding
also stays a separate unresolved product decision; this workflow does not add it.
