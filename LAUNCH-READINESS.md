# Splash launch readiness

## Agreed direction

- Keep the public HTML/CSS/JavaScript site alongside the Flutter/Dart application.
- David selected the blue splash and car silhouette with bold lettering, cleaned up on white. The supplied transparent PNG is integrated unchanged in the public header/footer and Flutter app bar, on white surfaces for legibility. Both owners still review official branding.
- Both owners have equal authority and review all business decisions.
- Regular services are first come, first served. Wax and polishing use appointment requests.
- The vehicle progress tracker remains an idea only. No prototype or implementation is approved.
- Real customer photos are pending the owners' Drive folder.

## Completed in this review

- Checked the live GitHub Pages desktop page and exercised the Interior gallery filter. It filtered the cards but did not expose selection state to assistive technology.
- Added initial and interactive `aria-pressed` state to gallery filters.
- Added a visible-on-focus skip link and transferred keyboard focus when following section links.
- Made JavaScript scrolling respect reduced-motion preferences.
- Corrected the hours calculation to use America/Los_Angeles, including daylight-saving time, without changing the listed schedule.
- Raised the dim text color and removed whole-card opacity from Sunday hours.
- Made gallery grid minimums shrink with their container and removed the quote text minimum width.
- Made placeholder captions visible without hover and removed their misleading pointer cursor.
- Added regression tests for opening/closing boundaries, winter/summer time and gallery filter state.

## Verification limits / next technical work

- The audit browser could access the live public website but blocked the workspace-local preview. The live site is main, not this PR branch.
- The edited branch still needs visual verification at 320, 390, 768 and 1440 CSS pixels, 200% zoom, keyboard-only navigation and reduced motion.
- Flutter rendered screens still need a browser/device audit; no Flutter code changed in this pass.
- These fixes do not establish WCAG conformance. Complete contrast and assistive-technology checks remain open.
- Prepare an isolated branch preview before merging. PR #2 remains the review boundary; do not deploy this branch as the live site implicitly.
- Revisit gallery lightbox keyboard handling when real photos are provided; current placeholders do not open a lightbox.

## Owners / content needed

| Item | Current state | Next action |
| --- | --- | --- |
| Logo | David's preferred direction selected | Exact transparent PNG integrated on review branch; both owners review final branding |
| Photos | Awaiting Drive folder | Obtain real photos and publication permission |
| Address | Page says 851 Showroom Pl; live embedded map labels 851 District Pl | Both owners confirm the correct address and map pin |
| Business details | Phone, hours, services and claims still require verification | Complete English/Spanish questionnaires |
| Domain | Prior audit reported DNS setup unresolved | Verify registrar, domain and hosting configuration before launch |
| SEO | Rating markup, business type and sitemap still need review | Correct against verified business details |
| Optional features | Tracker, backend, notifications and payments pending decisions | Keep in questionnaire backlog until agreed |

Owner-entered questionnaire answers are preserved in their existing files. This document records progress and open work; it does not replace those answers or constitute owner approval.
