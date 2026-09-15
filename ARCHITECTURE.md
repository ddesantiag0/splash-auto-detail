# Splash Auto Product Architecture

## Decision

Splash Auto uses a hybrid web and application architecture:

- The repository root remains the public, SEO-focused HTML website.
- `app/` contains the Flutter/Dart customer and operations application.
- Backend services will be introduced behind explicit APIs rather than embedded
  into either client.

This protects local-search visibility while allowing the interactive product to
share a Flutter codebase across web, iOS, and Android.

## Product boundaries

| Surface | Responsibility | Current state |
| --- | --- | --- |
| Public website | Services, business details, gallery, local SEO, contact | Existing static site |
| Customer app | Wax/polishing requests, quotes, vehicles, history, reminders | Foundation in `app/` |
| Owner area | Publish current shop wait from Flutter | Implemented; backend/account activation pending |
| Shop wait backend | Supabase Auth, owner membership, public wait, realtime | Schema and clients implemented; project selection pending |

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

1. Establish the Flutter shell and design system.
2. Confirm real services, intake fields, and scheduling rules with the business.
3. Select and implement the backend contract.
4. Complete the customer appointment-request flow.
5. Build the staff request queue and confirmation workflow.
6. Add accounts, saved vehicles, history, reminders, and payments only when the
   underlying business process is ready.

## Approved live shop wait

Both owners approved a public, manually maintained shop-wait indicator. The HTML website and Flutter app read the same Supabase status; the Flutter `/owner` route manages it. Estimated minutes mean time **until service starts**, not completion time. Status expires unless refreshed. Customers need no account. Only administrator-enrolled owner accounts may update it, with equal permissions and optimistic concurrency checks.

This narrowly scoped backend does not activate customer bookings, individual vehicle tracking, payments, or notifications. See [connection and activation checks](availability/README.md).
