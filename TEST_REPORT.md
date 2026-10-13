# Test report

Environment: Windows, Android Studio bundled JBR (JDK), Gradle 9 / AGP 9, compile/target SDK 35,
min SDK 24. `JAVA_HOME` pointed at the Android Studio JBR.

## Command run

```bash
./gradlew clean testDebugUnitTest lintDebug assembleDebug
```

Result: **BUILD SUCCESSFUL** — 52 tasks executed.

```
> Task :app:testDebugUnitTest
> Task :app:lintDebug          (0 errors)
> Task :app:assembleDebug      → app/build/outputs/apk/debug/app-debug.apk
BUILD SUCCESSFUL
```

---

## Executed — unit tests (JVM, no device)

`./gradlew :app:testDebugUnitTest` — **104 tests, 0 failures, 0 errors.**

| Class | Tests | Covers |
|---|---|---|
| `AvailabilityEngineTest` | 7 | Slot generation from schedules, ports, blocks and reservations; conflicts; summaries |
| `BookingAndMeterTest` | 12 | Free-slot booking, double-booking prevention, port-level connector rejection, paused/pending rejection, meterless policy, price preview, cancellation policy, meter simulator, receipt lines |
| `ChatManagerTest` | 8 | Number masking, sanitising, off-platform detection, thread rules, quick questions, audit fields |
| `EnforcementPolicyTest` | 5 | Warning → fine → suspension → ban escalation; no action on unverified accusations |
| `EngineUnitTest` | 11 | Corridor filtering + exclusion reasons, trade-off + backup stop, SoC override authority, no-safe-charger state, relaxed reserve, meter-only billing, zero-energy rule, geo helpers, port labels |
| `GoogleDirectionsClientTest` | 8 | **New** — Directions parsing: metres/seconds, traffic-duration preference, HTML stripping, geometry order, `REQUEST_DENIED` / `ZERO_RESULTS` / no-geometry failures, labelled straight-line fallback |
| `GoogleNavigationProviderTest` | 6 | **New** — session lifecycle on the production provider: idle, start, progress, reroute, arrival, stop |
| `PaymentManagerTest` | 8 | Authorization, idempotency, capture, refund, release, gateway-offline failure |
| `PolylineTest` | 3 | **New** — Google encoded-polyline decoder against the canonical example; empty and two-point inputs |
| `RoleGuardTest` | 4 | Consumer / Host / Admin boundaries incl. the dual-role account |
| `RoutePlannerGoogleTimeTest` | 3 | **New** — Google's measured drive time overrides the average-speed estimate; total-journey maths |
| `RouteProgressTest` | 6 | **New** — fraction along the route, remaining distance/time, next-maneuver selection |
| `StationMarkerModelTest` | 6 | **New** — marker styling, no-verified-meter vs verified-meter wording, no host-contact leak |
| `StationVisibilityTest` | 7 | **New** — approved vs pending/rejected/paused visibility; coordinate validity |
| `SettlementFunctionContractTest` | 4 | Settlement SQL functions against the documented contract |
| `UserProfileRowTest` | 6 | `public.users` profile row + `auth.users` trigger checked against `supabase/schema.sql` |

Previously present and now **removed** (their subject was deleted in the migration):
`MercatorTest` (Web Mercator projection for the OSM tile view) and `OsrmRouterTest` (OSRM parsing).

## Executed — lint

`./gradlew :app:lintDebug` — **0 errors** (322 warnings, unchanged in kind from the pre-existing
codebase). Three pre-existing lint **errors** in `MainActivity` (`ResourceType` — raw integers passed
to `setSelectedItemId`) were fixed properly by giving the bottom-navigation items real ids in
`res/values/ids.xml` rather than suppressed.

## Executed — build

`./gradlew :app:assembleDebug` — debug APK produced.

---

## Skipped / not run, and why

| Test | Status | Reason | Manual step to run it |
|---|---|---|---|
| Instrumentation tests (`androidTest`) | **Not run** | No emulator/device is attached in this environment; the project has no instrumentation sources yet | Start an emulator, then `./gradlew :app:connectedDebugAndroidTest` |
| Android Auto discovery / display | **Not run** | Needs the Desktop Head Unit or a head unit | Enable developer mode, `adb forward tcp:5277 tcp:5277`, run `desktop-head-unit`, then launch the Amperly car service |
| Live map tiles, Place autocomplete, Directions, Geocoding | **Not run** | Need the real `GOOGLE_MAPS_API_KEY`, an enabled/billed Cloud project, and a device. The **parsers and rules are unit tested** with captured payloads instead | Set `GOOGLE_MAPS_API_KEY` in `local.properties`, run the app on a device |
| Location-permission granted/denied, no-fix states | **Not run** | Device-only flows | Run on a device and toggle location permission in Settings |
| Spoken voice guidance | **Not run** | Requires the licence-gated Google Navigation SDK, which is not enabled | Enable the Navigation SDK entitlement and swap the provider per `GOOGLE_NAVIGATION_MIGRATION.md` §6 |

### What was verified by execution vs by inspection

- **Executed and green:** all 104 unit tests, lint (0 errors), debug APK assembly.
- **Verified by inspection only (not executed):** the runtime behaviour of the Google map, Place
  autocomplete, Directions and Geocoding calls, the Android Auto navigation template, and voice
  guidance. These are **not** claimed as verified.
