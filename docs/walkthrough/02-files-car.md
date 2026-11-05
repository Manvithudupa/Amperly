# 02 — Files: Android Auto (`car/`) — 14 files

The car experience is the Android Car App Library (`androidx.car.app`), category `navigation`, with a real map painted into the host surface. It shares `AmperlyRepository`, `AppStateStore`, `AuthManager` and the engines with the phone; it is not a separate app and has no separate database.

Read in full: `AmperlyCarAppService`, `AmperlyCarSession`, `CarBridge`, `CarScreenFactory`, `CarMap`, `RouteOverviewCarScreen`, `NavigationCarScreen`. The other seven screens were inventoried by declaration/usage and are marked **[INFERRED]** where behaviour is inferred. Declaration lines: `09-symbol-index.md`.

---

## Service and session

### `AmperlyCarAppService.java` (21 lines)
`CarAppService` entry point declared in the manifest (`androidx.car.app.CarAppService` with category `androidx.car.app.category.NAVIGATION`, automotive descriptor `automotive_app_desc.xml` → `template`). `createHostValidator()` returns `ALLOW_ALL_HOSTS_VALIDATOR` (required for sideloaded/desktop-head-unit testing; Play requires the default allow-list in production). `onCreateSession()` returns `AmperlyCarSession`.

### `AmperlyCarSession.java` (72 lines)
One projected session. `onCreateScreen`:
- sets `AppStateStore.setCarConnected(true)`;
- creates an `AndroidAutoSession` row (`ROUTE_OVERVIEW`, current SoC or 0) and saves it via the repository;
- registers a `DefaultLifecycleObserver`; on `ON_DESTROY` sets carConnected=false and writes a `DISCONNECTED` row with `disconnectedAtMs` (car-app 1.4.0's `Session` has no `onDestroy` override, hence the observer);
- returns `RouteOverviewCarScreen`.

No sign-in happens in the car: it uses the phone's `AuthManager` state (same process only while projected; otherwise `getCurrentUserId` may be null and screens show their empty state).

---

## Bridge

### `CarBridge.java` (241 lines)
The only car→data surface.

`load(repo, callback)` returns a `Snapshot`:
- plan from `AppStateStore` or `repo.getActiveRoutePlanSync(userId)`;
- vehicle from the repository; active reservation;
- if a plan exists: approved stations filtered by `SoCEstimatorEngine.safeAlternatives(..., 5)` from the plan origin, SoC = stored/confirmed value else `plannedStartSoc`;
- best station + detail string (detour, connectors, kW, ₹/kWh);
- `routeTitle()` (`origin → destination (km)`) and `summaryLine()` (battery ± actual/estimated, usable km, reserve).

`applyBatteryUpdate(repo, actualSoc, callback)`:
- requires an active plan ("Plan a trip on your phone first.");
- uses the plan origin as the car's position (no GPS in the car) and `totalDistanceKm * 0.6` as remaining distance;
- calls `SoCEstimatorEngine.applyAuthoritativeSocOverride`, saves the `BatteryUpdate`, updates `AppStateStore` (correction, summary, no-safe-charger message);
- returns "Battery N% applied…" with the next safe charger or the no-safe-charger warning.

`reserveNextFreeSlot(repo, stationId, callback)`:
- refuses a station without paid-energy billing ("No verified meter here. Discovery only.");
- scans today then tomorrow (2 days) for the first free `AvailabilityEngine` slot (12-slot window);
- resolves the `ChargerPort` for the slot;
- calls `repo.createReservationConfirmed` (server RPC, per-port lock);
- on success sets `AppStateStore` active reservation/booking code and returns "Reserved <port> at <station> · code <code>".

It never collects payment, never writes meter readings, and never approves a station.

---

## Screens

### `CarScreenFactory.java` (46 lines)
`ScreenType { ROUTE_OVERVIEW, NAVIGATION, CHARGER_LIST, CHARGER_DETAILS, SOC_UPDATE, RESERVATION_STATUS }`; `createScreen(type, context[, stationId])` switches to the concrete screen, defaulting to `RouteOverviewCarScreen` and passing `stationId` only to charger details.

### `RouteOverviewCarScreen.java` (263 lines)
The landing screen and the most important one.
- On every `onGetTemplate`: starts `CarMap`; if no snapshot yet, loads it asynchronously and invalidates; builds the sidebar.
- Uses `MapWithContentTemplate` (car API **7+**) with a `MapController` and action strip; on older hosts falls back to the plain `ListTemplate` (same sidebar) because the host cannot draw side content.
- `updateMap`: centre = plan origin (zoom 11), destination pin, recommended charger pin, up to 6 reachable station pins; with no plan, centre on the recommended charger (zoom 14) or India (zoom 4).
- Sidebar rows: trip title/summary; recommended stop (→ `ChargerDetailsCarScreen`) or no-safe-charger message or "no stop needed"; Start navigation (→ `NavigationCarScreen`); chargers along route (count → list); Update actual battery (→ `SoCUpdateCarScreen`); reservation row (→ status); Trip history; Reservations; Vehicle; Settings.
- Action strip: SOS → toast `car_sos_notice` and pushes reservation status (no emergency call).
- `CarMap` is stopped in `onDestroy`.

### `CarMap.java` (253 lines)
Paints a **Geoapify static map** into the car `Surface` because MapLibre needs an Android View and the car host gives only a Surface.
- `start()` registers a `SurfaceCallback` with `AppManager`; `stop()` unregisters, shuts down the single-thread executor, drops the surface.
- `show(lat, lng, zoom, pins)` stores the view and renders.
- `buildUrl()`: `/v1/staticmap?style=osm-bright`, width/height (min 320×240), `center=lonlat:lng,lat`, zoom, `attribution=default`, up to **6** markers (`lonlat:…;color:%23RRGGBB;size:medium`), then `MapConfig.withKey`.
- Download on the executor; draw on the main thread with `Surface.lockCanvas`, dark background `#15171A`, bitmap scaled to the surface; every surface race is caught.
- Pins: `station()` = `0F5C4D`, `destination()` = `B3261E`.
- No map is drawn when `MapConfig.isConfigured()` is false.

### `NavigationCarScreen.java` (153 lines)
Projected `NavigationTemplate` (driver-safe):
- actions: Update battery (→ `SoCUpdateCarScreen`), Stop (pop);
- no plan → `MessageInfo` ("no trip" strings);
- current step: "Continue toward <destination>", road line with total km;
- next step: battery cue with actual/estimated label;
- `TravelEstimate`: total distance, arrival time = now + `plan.totalJourneyMinutes`, remaining seconds, trip text with destination and first non-backup stop name (loaded from `repo.getRouteStopsSync` once).
- The Javadoc still calls it "the Android Auto side of the Google navigation session" and mentions a Google Navigation SDK swap; **no Google Navigation SDK is present in the build** (Q5). Map/voice guidance stay on the phone; this screen shows no map of its own.

### Remaining screens (inventoried)
| File (lines) | Purpose |
|---|---|
| `ChargerListCarScreen.java` (84) | Glanceable list of safe reachable chargers; row opens details. **[INFERRED]** exact row fields |
| `ChargerDetailsCarScreen.java` (102) | One charger: name, connector/power/price, detour, Reserve action. **[INFERRED]** |
| `SoCUpdateCarScreen.java` (51) | Two-tap battery picker (no typing while driving), calls `CarBridge.applyBatteryUpdate`. **[INFERRED]** for the picker steps |
| `ReservationStatusCarScreen.java` (109) | Active reservation code/status/station/slot; entry point for QR/status. **[INFERRED]** |
| `TripHistoryCarScreen.java` (74) | Recent trips list. **[INFERRED]** |
| `VehicleCarScreen.java` (83) | Vehicle summary (battery/range/reserve). **[INFERRED]** |
| `CarSettingsScreen.java` (53) | Connection/app info. **[INFERRED]** |

All seven take `CarContext`, extend `Screen`, and return a Car App Library template; none writes to the database except through `CarBridge`/repository.

---

## Car-specific rules

- **Glanceability**: the car surface shows a trip summary, at most a handful of rows, and two actions. There is no text entry, payment form, meter reading, host control, or sign-in.
- **No GPS**: the car uses the plan origin; the phone refines position. This is stated in `CarBridge.applyBatteryUpdate`.
- **Shared state, no duplicate persistence**: `AppStateStore` carries the plan, SoC, reservation and no-safe-charger message; both surfaces read the same Room cache.
- **Manifest**: `AmperlyCarAppService` is exported with the car-app intent filter and `automotive_app_desc.xml`; `MainActivity` itself is the phone launcher.
- **Host validator**: `ALLOW_ALL_HOSTS_VALIDATOR` is a testing convenience and would be rejected by Play review for a production navigation app (Q6).
