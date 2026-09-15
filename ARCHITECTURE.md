# Splash Auto Product Architecture

## Decision

Splash Auto uses a hybrid web and application architecture:

- The repository root remains the public, SEO-focused HTML website.
- `app/` contains the Flutter/Dart customer and operations application.
- `backend/` contains the FastAPI service, with MongoDB persistence and explicit
  HTTP/WebSocket APIs shared by both clients. Cloud activation is pending.

This protects local-search visibility while allowing the interactive product to
share a Flutter codebase across web, iOS, and Android.

## Product boundaries

| Surface | Responsibility | Current state |
| --- | --- | --- |
| Public website | Services, business details, gallery, local SEO, contact | Existing static site |
| Customer app | Local wax/polishing request draft and public shop wait | Foundation in `app/`; no request submission or customer accounts |
| Owner area | Publish current shop wait from Flutter | Implemented; backend/account activation pending |
| Shop wait backend | FastAPI owner auth, MongoDB status/sessions, WebSockets | Backend and clients implemented; Atlas/AWS activation pending |

## Release boundaries

Most Splash Auto services are first come, first served. The Flutter appointment
flow is limited to wax and polishing requests and must not be linked publicly
until all of the following are implemented and verified:

1. Server-side request persistence and validation.
2. Staff-visible appointment queue and confirmation workflow.
3. Authentication and authorization for customer and staff data.
4. Spam/rate-limit protection and operational notifications.
5. Privacy policy, retention rules, and production monitoring.
6. Browser, mobile, accessibility, and end-to-end testing.

## Recommended delivery order

1. Maintain the existing Flutter shell, website, backend contract, and CI checks.
2. Confirm dedicated Splash hosting/account details and activate the approved
   shop-wait backend with both owners' separate logins.
3. Verify the configured customer and owner screens on real devices, including
   English/Spanish, light/dark mode, reconnects, and expired estimates.
4. Complete owner discovery before extending the appointment-request draft into
   real submission, storage, and staff confirmation.
5. Add customer accounts, saved vehicles, history, reminders, or payments only
   after the corresponding business requirements are approved.

See [development workflow](docs/DEVELOPMENT-WORKFLOW.md) for repository ownership,
review gates, and the phased organization plan. Splash currently represents one
shop with two equal owners; a multi-business organization model is not implied.

## Approved live shop wait

Both owners approved a public, manually maintained shop-wait indicator. The HTML website and Flutter app read the same FastAPI/MongoDB status; the Flutter `/owner` route manages it. Estimated minutes mean time **until service starts**, not completion time. Status expires unless refreshed. Customers need no account. Only administrator-enrolled owner accounts may update it, with equal permissions and optimistic concurrency checks.

This narrowly scoped backend does not activate customer bookings, individual vehicle tracking, payments, or notifications. See [connection and activation checks](availability/README.md).
