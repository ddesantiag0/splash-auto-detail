# Splash Auto App

Flutter/Dart application for Splash Auto Detail's interactive customer and
operations experiences. The public marketing site remains at the repository
root so search engines receive semantic HTML.

## Included in this foundation

- Responsive phone, tablet, and desktop shell
- Shared Splash Auto color and typography system
- Customer home screen
- Validated wax and polishing appointment-request draft flow
- Account and staff-area boundaries for future development
- Domain model and widget tests
- Live shop-wait customer card and authenticated owner controls (`/owner`)
- Supabase integration prepared; project and owner enrollment pending

Most services remain first come, first served. Only wax and polishing work uses
the appointment-request flow. No customer request is transmitted yet. Backend submission, authentication,
availability, pricing, notifications, and payments must be connected before the
appointment flow is released publicly.

## Run locally

The web host is included. Install the current stable Flutter SDK, then from
this directory run:

```bash
flutter pub get
flutter run -d chrome
```

## Verify

```bash
flutter analyze
flutter test
```

## Generate native host projects

The application code is cross-platform. Generate the platform host files with
the locally installed Flutter SDK so they match that SDK version:

```bash
flutter create . --platforms=android,ios
```

Review generated files before committing them. Do not overwrite the files in
`lib/`, `test/`, `web/`, or this README.

## Live shop wait setup

See [availability setup](../availability/README.md). Configure `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY` as Dart defines when building. Without them, customer screens safely report unavailable and the owner screen explains that access is not connected. This feature is independent of appointment submission.
