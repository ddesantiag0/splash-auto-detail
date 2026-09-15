# Device language and appearance

The website follows `prefers-color-scheme`; Flutter uses `ThemeMode.system`. Both have light and dark palettes and react to preference changes exposed by the browser or operating system. The website reads `navigator.languages`; Flutter reads the platform locale list. The first supported language in that list wins. English and Spanish (including regional variants such as en-GB and es-MX) are supported. The fallback is English.

There is no location lookup, IP inference, account requirement, preference storage, or translation service. The browser can override the operating system's settings, so the website follows the preferences that the browser exposes. The logo remains transparent and unchanged.

`es.json` is the shared Spanish copy catalog, keyed by original English UI strings. Run `python3 scripts/generate-localization.py` after editing it to regenerate `translations.js` and `app/lib/core/localization/spanish.dart`. Flutter's built-in Material, Cupertino and widget localizations handle controls such as the date picker. App dates use Material's localized date format. User-entered vehicle/contact information is not translated.

The public page retains its English HTML fallback for no-JavaScript clients and existing crawlers; the page language and visible/accessibility copy update for Spanish visitors. Separate Spanish URLs, translated structured data, and localized social metadata are outside this UI change. Translations preserve the existing business statements and do not verify pending owner claims.

Verification: website language-selection and live-update tests, synchronized catalog tests, existing site checks, and Flutter tests covering es-MX at phone/desktop widths in both themes, translated validation/calendar controls, fallback locale resolution and live device preference changes. Full rendered website checks remain pending the branch preview access noted in LAUNCH-READINESS.md.
