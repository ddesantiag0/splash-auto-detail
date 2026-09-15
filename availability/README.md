# Live shop wait

Both owners approved a manually published status and estimated time **until service starts**. This does not add appointment submission or individual vehicle tracking.

The HTML website and Flutter app now connect to the independent [FastAPI/MongoDB backend](../backend/README.md). Set the public HTTPS origin in `config.js` (`apiUrl`) and use the same origin as Flutter's `SPLASH_API_URL` Dart define. Run `npm run build:availability` after JavaScript changes. No API keys or MongoDB credentials belong in either client.

Statuses: Available, Getting busy, Very busy, Closed. Color supplements text. The owner chooses a wait range and 15/30/60-minute freshness per update (initially 30). After expiry, customers are asked to call. Estimates are not countdowns and may change. Closed also expires; this feature does not invent holiday rules.

WebSockets deliver status/server-time snapshots every two seconds; clients reconnect after disconnects and retain a 30-second HTTP polling fallback. Failed reads hide estimates, and freshness is checked every ten seconds. Either owner can update through the Flutter `/owner` route. Version checks reject stale saves instead of overwriting the other owner.

The previous unprovisioned Supabase implementation has been removed. Live activation still requires Splash's Atlas/AWS setup, HTTPS API origin, and owner enrollment. Public clients show unavailable while unconfigured. See the backend guide for local setup, security, deployment and verification.
