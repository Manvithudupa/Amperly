# 07 — Quality report

This is a code audit, not a penetration test. Every finding cites the file(s) where it is visible. Severity: **H**igh (release/security/correctness), **M**edium (user-visible wrong behaviour or maintenance risk), **L**ow (drift/cosmetic).

---

## 1. Findings

### Q1 — Two different average speeds (M)
`core/common/GeoUtils.drivingMinutes` and `RoutePlannerEngine` estimate at **45 km/h**; `engine/routing/TripTimeEngine` uses **60 km/h**. The planner's `totalJourneyMinutes` (what the phone and car show) uses 45, but any caller of `TripTimeEngine` gets an ETA ~25 % shorter. There is no single speed constant.
**Fix direction:** one `TravelTime` constant/function used by both; delete or delegate `TripTimeEngine`.

### Q2 — `DirectionsRoute.getDurationInTrafficMinutes()` returns 0 when traffic data is absent (M)
The Javadoc says it falls back to the normal duration; the implementation returns `0`. Callers that format the value directly will show “0 min”. The planner avoids it, but the contract is wrong.
**Fix direction:** return `durationMinutes` in the fallback, or rename to `hasTraffic` + nullable getter.

### Q3 — README says Room v5; database is v6 (L)
`README.md` (data section) vs `AmperlyDatabase` (`version = 6`, `MIGRATION_5_6`). Operators following the README will look for the wrong schema.
**Fix:** update the README and note the migration.

### Q4 — README references a non-existent `AmperlyApplication.java` (L)
The class is not in `app/src/main/java`; there is no `Application` subclass in the manifest. Any setup instruction that depends on it is wrong.
**Fix:** remove the reference or add the class if startup work was intended.

### Q5 — Google Maps comments/migration doc vs MapLibre + Geoapify code (M)
`MAPS_MIGRATION.md` and comments in `MapContainerView`, `RouteProgress`, `NavigationCarScreen` describe Google Maps/Navigation. The build contains MapLibre, Geoapify routing/geocoding/static maps, and no Google Maps/Navigation SDK. `NavigationCarScreen` even mentions a licence-gated SDK swap that is not present.
**Risk:** a maintainer enables the wrong key/SDK or assumes traffic data that does not exist.
**Fix:** rewrite the docs/comments to the actual stack; remove the Google wording.

### Q6 — Car host validator allows all hosts (H for Play release)
`AmperlyCarAppService.createHostValidator()` returns `HostValidator.ALLOW_ALL_HOSTS_VALIDATOR`. This is correct for the Desktop Head Unit and sideloaded testing, but a navigation-category app submitted to Play is expected to use the default allow-list. It also weakens host authenticity in production.
**Fix:** use the default validator for release (or a debug-only build config).

### Q7 — README claims ~150 tests; the tree has 24 JVM test classes + 1 instrumented template (L)
`README.md` §9 vs `app/src/test` (24 files) and `app/src/androidTest` (1). The method count is ~140+, not 150 classes, but the README wording overstates coverage.
**Fix:** state “24 test classes” and what they cover.

### Q8 — README test list is stale (L)
The README names 20 test classes; the tree has 24, and several newer classes are easy to miss. Documentation drift.
**Fix:** generate the list from `app/src/test` rather than maintaining it by hand.

### Q9 — “Seeder” comments with no seeder (L)
Comments in `AmperlyRepository`/entities refer to a local seeder; there is no seed data anywhere, and `supabase/README.md` explicitly says the app ships none. Confusing during onboarding.
**Fix:** delete the stale comments.

### Q10 — Lifecycle/LiveData dependencies are largely unused by the UI (L)
Several DAOs return `LiveData`, but no fragment observes it; screens read synchronously on the repository executor. The dependency and the reactive surface add weight without a consumer.
**Fix:** either observe LiveData (lifecycle-correct) or drop it and keep synchronous reads.

### Q11 — Version catalog drift (M)
`gradle/libs.versions.toml` declares versions that differ from the literal pins in `app/build.gradle.kts`; several catalog entries are unused, and some dependencies are only literal. Upgrading via the catalog will not upgrade what the app actually builds.
**Fix:** one source of truth (catalog aliases everywhere).

### Q12 — Car copy is partly hard-coded (L)
`CarBridge`, `RouteOverviewCarScreen` and `NavigationCarScreen` contain English literals (“No active trip”, “Plan a trip on your phone…”, “Recommended stop”, “Start navigation”, “Sessions: …”) alongside `strings.xml` lookups. The car is not fully localisable and diverges from phone copy.
**Fix:** move all car copy to resources.

### Q13 — Destructive migration fallback (M)
`AmperlyDatabase` uses `fallbackToDestructiveMigration()` in addition to `MIGRATION_5_6`. A future version without a migration silently wipes the cache. The server can refill it, but unsynced local edits (battery audit, chat drafts) are lost.
**Fix:** explicit migrations for every version; keep destructive fallback only in debug.

### Q14 — No CI and no lint baseline (M)
No `.github/workflows`, no Jenkins/GitLab config, no `lint.xml`/baseline. Tests and lint run only when a developer remembers. Static-analysis regressions (API level, unused resources, hard-coded text) are unguarded.
**Fix:** a CI job running `./gradlew test lint` on every push.

### Q15 — No offline write queue (M by design)
`supabase/README.md` states a refused write is reported, not queued. For a charging app used in basements/remote chargers, a booking or session finalization attempted offline is simply lost until the user retries. This is a deliberate MVP trade-off, but it should be a product decision, not a surprise.
**Fix direction:** WorkManager outbox with idempotency keys (payments already have `idempotencyKey`).

### Q16 — No foreign keys between domain tables (M)
Only `users.authUserId → auth.users` is a real FK. Reservations, sessions, stops and the other domain rows are linked by ids with no constraints; orphan rows are possible if a delete path is added outside the auth cascade. RLS limits who can create them but not referential integrity.
**Fix:** add FKs with appropriate `on delete` once the delete semantics are settled.

### Q17 — Car remaining-distance heuristic (M)
`CarBridge.applyBatteryUpdate` passes `plan.getTotalDistanceKm() * 0.6` as the remaining distance because the car has no GPS. On a trip that is 90 % complete, the car still assumes 60 % remains, so its recommended charger and ETA can be wrong. The phone corrects this when it has a fix.
**Fix:** persist last known progress (TripSessionStore already exists) and pass it to the car.

### Q18 — 12-hour SoC freshness (L)
`SocStore` treats a stored battery value as valid for 12 h. A car parked overnight can show yesterday's SoC as “actual” the next morning. The UI does label actual vs estimated, but the value is stale.
**Fix:** shorten the TTL or timestamp the reading in the UI.

### Q19 — Enormous classes (M maintainability)
`AmperlyRepository` 1,935 lines; `RoutePlannerFragment` 1,066; `ChargerDiscoveryFragment` 692; `AdminDashboardFragment` 629; `RoutePlannerEngine` 613. They mix I/O, validation, formatting and view wiring. Unit testing is limited to pure engines.
**Fix direction:** split repository by domain; extract presenters/use-cases; view binding would remove manual `findViewById`.

### Q20 — No ViewModel / state restoration for forms (M)
Tabs survive switching because fragments are hidden, and tab tags survive rotation, but there is no `ViewModel`/`SavedStateHandle`. Process death during a long form (station registration, vehicle) loses input. No `onSaveInstanceState` in the fragments was observed.
**Fix:** ViewModel + saved state for form screens.

### Q21 — No push notifications (L)
Notifications are a Room table pulled by sync; there is no FCM. A user only sees a booking/approval/dispute update when they open the app and sync. Acceptable for a pilot, but the inbox looks real-time when it is not.
**Fix:** document it, or add FCM + a server trigger.

### Q22 — No certificate pinning / no gateway (L)
HTTPS + system trust anchors only. For a payments-adjacent app, pinning Supabase/Geoapify would harden MITM resistance. No payment gateway is integrated, so there is no charge path to protect yet.
**Fix:** pin when the gateway is added.

---

## 2. What is done well

- **Fail-closed auth**: refresh failure clears the session; a secret key is refused at build and runtime; `authUserId`/RLS bootstrap is documented and repaired by a backfill.
- **Server-authoritative money and slots**: booking via `create_reservation` with a per-port lock; settlement recomputes from meter readings; invoices/payments pinned by triggers; admin-only RPCs for approval/refund/enforcement.
- **Security defaults**: cleartext denied, backup excluded (both APIs), EncryptedSharedPreferences, masked chat numbers, no secrets in the repo, `local.properties`/keystore gitignored.
- **Pure engines**: availability, billing, reservation, planner, SoC, enforcement and analytics are testable without Android; 24 JVM test classes cover them.
- **Car safety**: no typing, payment, meter or host control on the car surface; a static-map approach avoids GL/lifecycle races; list fallback below car API 7.
- **Failure copy**: most refusals have a specific string, not a generic error; offline vs permission vs conflict are distinguished.

---

## 3. Test inventory

`app/src/test` — 24 classes: `AppStateStoreTest`, `AvailabilityEngineTest`, `BookingAndMeterTest`, `ChatManagerTest`, `EnforcementPolicyTest`, `EngineUnitTest`, `GeoapifyNavigationProviderTest`, `GeoapifyPlaceParserTest`, `GeoapifyRoutingClientTest`, `HostAnalyticsEngineTest`, `PaymentManagerTest`, `RequestSequenceTest`, `RoleGuardTest`, `RouteCacheTest`, `RoutePlannerRouteTimeTest`, `RouteProgressTest`, `StationMarkerModelTest`, `StationVisibilityTest`, `TripTimeEngineTest`, `UserMessagesTest`, `SupabaseRestTest`, `SyncReconcilerTest`, `SettlementFunctionContractTest`, `UserProfileRowTest`.

`app/src/androidTest` — 1 `ExampleInstrumentedTest` (package/context template).

Coverage shape: engines, parsers, routing cache/throttle, sync diff, settlement function contract, profile row serialisation. **Not covered**: `MainActivity`, fragments, adapters, `AmperlyRepository` (1,935 lines), `SupabaseAuth` token refresh, `SyncEngine` end-to-end, car screens, RLS policies (no pgTAP/SQL tests), UI flows/accessibility. No coverage tool is configured.

The test count is meaningful for the pure layer but does not validate the app's riskiest paths (auth refresh, sync, booking RPC wiring, role gating). A green `./gradlew test` is not evidence that those work.

---

## 4. Security posture summary

| Area | State |
|---|---|
| Transport | HTTPS only; cleartext denied globally; no pinning |
| Tokens | EncryptedSharedPreferences; legacy plain file migrated/cleared; fail-closed refresh |
| Authorization | Postgres RLS on all 23 tables; admin-only RPCs; privilege-escalation trigger |
| Money | Server recomputes; invoices client-read-only; payment fields pinned |
| Secrets | Publishable key only; secret-key rejection at build + runtime; keys gitignored |
| Device data | Backup/device-transfer excluded; no export; cache wiped on account switch |
| Chat | Masked numbers; reservation-scoped threads; expiry/report/block |
| Car | No sensitive forms; host validator is the weak point (Q6) |
| Client trust | The app is not a security boundary; RLS is. A modified APK still cannot self-approve, self-pay or promote itself |

---

## 5. Performance notes (no benchmarks run)

- All repository work is serialised on a **single-thread executor**; a large pull can queue every screen's read behind it.
- Pull is up to 500 × 20 rows per table; id reconciliation another 500 × 40. On a cold cache this is a lot of small PostgREST calls.
- The phone map is MapLibre (GL); the car map downloads a static image per trip/position change, deduplicated by URL, max 6 pins.
- `RoutePlannerFragment` (1,066 lines) rebuilds large parts of its view on each result; no `DiffUtil` was observed in the adapters (they use `notifyDataSetChanged`-style updates).
- No baseline profiles, no startup tracing, no memory profiling. Claims about speed would be unsupported.

---

## 6. Documentation drift register

| Document | Claim | Reality |
|---|---|---|
| `README.md` | Room v5 | v6 |
| `README.md` | `AmperlyApplication.java` | absent |
| `README.md` | ~150 tests / 20 classes | 24 JVM + 1 instrumented |
| `MAPS_MIGRATION.md` | Google Maps migration | MapLibre + Geoapify |
| Comments | “Google” map/navigation | MapLibre/Geoapify |
| Comments | local seeder | no seed data |
| `PITCH.md` | product narrative | not a code contract; no verification attempted |
| `SECURITY_REVIEW.md` | prior review | useful context; findings above are code-derived, not copied |

`PITCH.md` is untracked in git (`?? PITCH.md`); the audit did not modify it.
