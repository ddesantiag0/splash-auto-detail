# Live shop wait

Approved scope: either owner publishes a color status and estimated time **until service starts**. Estimates can change. This is separate from appointment requests and individual vehicle tracking.

## Connection required before activation

No Splash backend or owner accounts have been provisioned. Public clients currently show “Current wait unavailable”; owner controls clearly report that access is not connected. Do not call this operational until the hosted security and two-device checks below pass.

1. Select the Supabase organization and confirm project cost. Create a dedicated Splash project rather than repurposing an unidentified existing project.
2. Apply the migration in `supabase/migrations/`. It starts with an expired status and enables Postgres Changes for `shop_wait`.
3. Disable public signups. Set up each owner's own Auth account using their confirmed email and an approved account-setup process. Do not commit passwords or send invitations without authorization.
4. Add each confirmed Auth user UUID to `public.shop_owners` through the project administrator. Client users cannot grant themselves owner access. Both owners have identical permissions. Removing membership immediately blocks future writes.
5. Set the public project URL and publishable key in `availability/config.js`. Build Flutter with matching `--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_PUBLISHABLE_KEY=...`. Never use service-role or secret keys in either client.
6. Run `npm ci`, `npm run build:availability`, `npm test`, Flutter analysis/tests, and the release web build. Package and publish the separate review site.
7. Bookmark the Flutter owner route `/app/#/owner` on each owner's device, or use the Owner controls icon. Use personal device password managers; sign out on shared devices. Account recovery is handled through the project administrator until a recovery flow is configured.

## Behavior

- Explicit status choices: Available, Getting busy, Very busy, Closed. Colors supplement labels.
- Wait choices: 0–15, 15–30, 30–45, 45–60, 60–90, 90–120, 120–180, 180–240 minutes. No invented automatic queue or countdown.
- Owner chooses freshness for each update: 15/30/60 minutes, initially 30. All statuses, including Closed, expire. Hours and holiday overrides are not inferred here.
- Server timestamps determine expiry. Customer clocks are aligned to server time on reads.
- Realtime triggers refetches, with 30-second polling and refresh on return/reconnect. Failed reads or lost connection hide the estimate. Expiry is checked every 10 seconds.
- Version checks prevent silent overwrite if both owners edit the same snapshot. Reload latest values after a conflict or an uncertain save.
- Only the public operational status is replicated; no customer data or owner IDs appear in the public status record.

## Activation verification

Run hosted security advisors. With the public key, verify reads work and writes fail. With a non-owner login, verify writes and membership inserts fail. With both owner accounts, verify updates work and conflicting edits are rejected. Verify revocation blocks writes. Keep a customer website and Flutter screen open while updating from another device: both must update without refresh. Test expiry, offline/reconnect, incorrect device clock, English/Spanish, light/dark, and phone text scaling. Local embedded PostgreSQL tests cover RLS/constraints/timestamps/conflicts; they do not test hosted Auth or realtime delivery.
