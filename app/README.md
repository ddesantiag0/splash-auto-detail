# Splash Auto App

Flutter/Dart application for Splash Auto Detail's interactive customer and
operations experiences. The public marketing site remains at the repository
root so search engines receive semantic HTML.

## Included in this foundation

- Responsive phone, tablet, and desktop shell
- Shared Splash Auto color and typography system
- Customer home screen
- Validated appointment-request draft flow
- Account and staff-area boundaries for future development
- Domain model and widget tests

No customer request is transmitted yet. Backend submission, authentication,
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
