# Splash Auto Detail Website

A responsive static website for Splash Auto Detail, a family-operated auto detailing business in Chula Vista, California.

The repository now also contains a Flutter/Dart application foundation in
[`app/`](app/). The public site remains semantic HTML for local SEO, while the
Flutter application will own appointment requests, customer accounts, and
staff workflows for services that require scheduling. Regular service remains
first come, first served; wax and polishing work is handled by appointment
request. See [`ARCHITECTURE.md`](ARCHITECTURE.md) for the boundary and release
plan.

Business requirements and owner approvals are recorded in
[`OWNER-DISCOVERY.md`](OWNER-DISCOVERY.md), with a plain-language Spanish
version in [`OWNER-DISCOVERY-ES.md`](OWNER-DISCOVERY-ES.md).

The [development workflow](docs/DEVELOPMENT-WORKFLOW.md) explains the repository
boundaries, review process, and remaining launch work. The approved shop-wait
feature uses the [FastAPI/MongoDB backend](backend/README.md); cloud setup and
owner account enrollment are still pending.

## Implemented features

- Mobile-first HTML and CSS with a responsive navigation menu
- Click-to-call and Google Maps direction links
- Dynamic open/closed messaging based on published business hours
- Service, business-hours, contact, and location sections
- LocalBusiness structured data, canonical metadata, sitemap, and robots file
- Accessible section navigation and reduced-motion styles
- Automated checks for missing local assets, broken section links, and placeholder URLs

The gallery currently uses clearly labeled visual placeholders because verified business photographs are not stored in this repository. Add real, authorized work photos before presenting it as a customer portfolio.

## Local preview

No build step or runtime framework is required. Serve the directory with any static server, for example:

```bash
npx serve .
```

Then open the local address printed by the server. Opening `index.html` directly also works, though a local server better matches deployment behavior.

## Verification

Requires Node.js 18 or newer:

```bash
npm test
```

The tests confirm that page-level local assets exist, internal navigation targets resolve, and production markup does not contain known placeholder domains or missing photo references.

Pull requests also run Flutter analysis, tests, and a release web build,
backend tests against MongoDB (including real HTTP/WebSocket connections across
API processes), and a Docker image build through GitHub Actions.

## Deployment checklist

1. Confirm the phone number, street address, hours, services, and domain with the business owner.
2. Replace gallery placeholders with optimized, authorized photographs and accurate alt text.
3. Add a 1200×630 social-sharing image before enabling `og:image` and Twitter image metadata.
4. Deploy the static files to an HTTPS host.
5. Validate structured data, mobile layout, and production links after deployment.

See [SEO-CHECKLIST.md](SEO-CHECKLIST.md) and [SEO-GUIDE.md](SEO-GUIDE.md) for operational steps that require access to the business's accounts.

## Project structure

```text
index.html         Page content and structured data
styles.css         Responsive visual system
script.js          Navigation, hours, gallery, and accessibility behavior
app/               Flutter/Dart customer application
backend/           FastAPI service, owner authentication, MongoDB, Docker
availability/      Public shop-wait client and connection configuration
localization/      Shared Spanish catalog for website and Flutter
scripts/           Translation generation and review-site packaging
docs/              Development workflow and organization plan
test/              Static integrity checks
robots.txt         Search crawler policy
sitemap.xml        Canonical site URL
SEO-*.md           Deployment and local-search guidance
ARCHITECTURE.md     Hybrid product boundary and release plan
OWNER-DISCOVERY.md  Editable owner questionnaire and decision record
OWNER-DISCOVERY-ES.md Spanish owner questionnaire
```

## Content accuracy

The repository contains a website implementation, not evidence of professional certifications, search ranking, accessibility certification, or measured load times. Those claims should be made only after independent verification.

## License

See [LICENSE](LICENSE).
