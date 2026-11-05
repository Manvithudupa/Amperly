# 02 — Files: `core/` (32 files)

Read status: every file in this area was read in full. Line counts are from `00-manifest.md`. Exact declaration lines for every method named below are in `09-symbol-index.md`; this report cites the file and the symbol, and uses `path:line` only where the line itself was observed (constants, schema objects, layout ids).

The `core` package has no Android UI except `MapPanel`/`MapContainerView`; everything else is plain Java or Android-framework helpers that the fragments and the car surface share.

---

## `core/common` — 8 files

### `AppConstants.java` (72 lines)
Single source of role and policy literals. It defines `ROLE_CONSUMER`, `ROLE_HOST`, `ROLE_ADMIN` (used by `MainActivity.applyRole`, `AuthManager`, `RoleGuard`) and the enforcement actions `ENFORCEMENT_NONE`, `ENFORCEMENT_WARNING`, `ENFORCEMENT_FINE`, `ENFORCEMENT_SUSPENSION`, `ENFORCEMENT_BAN` (used by `EnforcementPolicyEngine` and `AdminDashboardFragment`). No Android imports; safe for unit tests.

### `Formatters.java` (258 lines)
Presentation-only helpers shared by phone and car: money (`₹`), energy (kWh), distances, durations, dates, connector lists (`connectorTypes`, used by `CarBridge.Snapshot` detail), booking-status labels (`bookingStatus`, used by `RouteOverviewCarScreen`), and relative time. It never changes stored values; screens call it at render time. Locale is pinned to `Locale.US`/`en-IN` for deterministic number shapes.

### `GeoUtils.java` (100 lines)
Geodesy and driving-time estimates. `distanceKm` is the haversine distance used by `SoCEstimatorEngine` and the station list; `detourKm` converts station distance into an out-and-back detour (`CarBridge` reads the stored `RouteStop.detourKm` instead); `detourMinutes` uses the same average speed; `drivingMinutes` is the planner/SoC ETA at **45 km/h**. This 45 km/h is the value the planner and `SoCEstimatorEngine` use; `TripTimeEngine` uses 60 km/h (see `07-quality-report.md`, finding Q1).

### `GeoapifyErrors.java` (36 lines)
Maps Geoapify HTTP/API failures to the `error_map_unavailable` / `error_place_search` / `error_address_lookup` string resources through `UserMessages`. It keeps provider error text out of the UI.

### `MapConfig.java` (88 lines)
Reads `BuildConfig.GEOAPIFY_API_KEY` and `BuildConfig.MAP_STYLE_URL`. `isConfigured()` gates map creation (`MapPanel`, `CarMap.render`), `withKey(url)` appends the key to static-map and style URLs, and the class exposes the OSM-Bright style URL. A missing key produces `R.string.map_setup_required` rather than a blank map.

### `RequestSequence.java` (26 lines)
Monotonic token used to discard stale asynchronous results (search responses, route lookups). A caller captures the current sequence, launches work, and only applies the result if the sequence is still current. Unit-tested in `RequestSequenceTest`.

### `UserMessages.java` (221 lines)
The single translation layer from exceptions/HTTP statuses/PostgREST codes to user-facing strings: `error_offline`, `error_permission`, `error_not_allowed`, `error_not_found`, `error_conflict`, `error_validation`, `error_rate_limited`, `error_server`, plus auth-specific messages (`error_auth_invalid_credentials`, `error_auth_email_unconfirmed`, `error_auth_already_registered`). `MainActivity`, `SignInFragment`, `Ux` and the repository's callbacks route failures through it. Unit-tested in `UserMessagesTest`.

### `ValidationUtils.java` (22 lines)
Email shape and password length (6 characters, matching `auth_password_too_short`). Used by `SignInFragment` before calling `SupabaseAuth`.

---

## `core/location` — 1 file

### `LocationProvider.java` (143 lines)
Wraps `FusedLocationProviderClient`/`LocationManager` behind a callback so fragments do not own permission logic. It checks fine-location permission, requests a single current fix or last-known fix, and reports failure as a message key rather than a raw exception. Consumers: `ChargerDiscoveryFragment` (distance and map centring), `RegisterStationFragment` (Use GPS), `InAppNavigationFragment`, `RoutePlannerFragment` (origin), `SafetySOSFragment` (live location flag).

---

## `core/map` — 4 files

### `MapContainerView.java` (40 lines)
A `FrameLayout` that forwards lifecycle to the MapLibre `MapView` it contains. Its comment still says "Google" although the implementation is MapLibre — documented drift, not a behaviour bug.

### `MapPanel.java` (649 lines)
The phone map component. Responsibilities observed: create the MapLibre map with `MapConfig` style, render station markers from `StationMarkerModel`, draw the planned route polyline, move the camera to a fix/route, handle marker taps (opens charger details), show the "map not configured" state, and expose `attach(...)`, `plotStations`, `plotRoute`, `plotDriverPosition`, `plotPicker`, `centerOn`/`followUser`, marker/map tap listeners, and lifecycle binding. It is embedded by `fragment_charger_discovery.xml` (`mapContainer`), `fragment_charger_details.xml`, `fragment_register_station.xml` (`stationMapContainer`), `fragment_route_planner.xml`, and `fragment_in_app_navigation.xml` (`navMapContainer`). Map attribution (`map_attribution`) is drawn over it.

### `StationMarkerModel.java` (148 lines)
Pure marker styling: `hue`/`color` choose the pin colour from availability, verification and highlight state; `argbFromHue` builds the ARGB value; `snippet` and `supportsBillingLabel` produce the map callout text. It uses no Android map types, so it is unit-testable (`StationMarkerModelTest`).

### `StationVisibility.java` (51 lines)
The discovery filter: a station is visible only when `approvalStatus == APPROVED`, `!isPaused`, and it is live on the marketplace (`ChargerStation.isLiveOnMarketplace()`). Hosts see their own pending/paused rows through host screens, not through this filter. Unit-tested in `StationVisibilityTest`.

---

## `core/nav` — 7 files

### `NavigationProvider.java` (149 lines)
Interface/abstract contract for turn-by-turn data: request a route between two points, expose distance, duration, geometry, and step list; cancel in-flight work. It keeps `InAppNavigationFragment` independent of the provider.

### `GeoapifyNavigationProvider.java` (163 lines)
Implementation over `GeoapifyRoutingClient`. Converts a `DirectionsRoute` into `NavigationState`/steps, formats the next instruction, and reports provider failures. Unit-tested in `GeoapifyNavigationProviderTest`.

### `NavigationState.java` (83 lines)
Immutable snapshot of a running navigation: route points, current step index, remaining distance, remaining minutes, arrival time, off-route flag, and `advance(distanceTravelled)`. Consumed by `RouteProgress` and `InAppNavigationFragment`.

### `Navigator.java` (104 lines)
The only fragment-navigation helper. `open(fragment, tag)` adds a page on top of the current tab's back stack; `openRoot(fragment, tag)` replaces the container for root-level pages (account, vehicle, safety, notifications). It asks `TabBackStackHost.currentTabBackStackName()` for the tab name, which is how pages stay attached to the tab they were opened from. `MainActivity` implements the host interface.

### `RouteProgress.java` (74 lines)
Pure progress maths: given a polyline and distance travelled, returns the remaining distance, ETA, progress fraction and the next step. Its comment still says "Google" although it is provider-neutral. Unit-tested in `RouteProgressTest`.

### `TabBackStackHost.java` (21 lines)
One-method interface: `currentTabBackStackName()`. Implemented by `MainActivity`; consumed by `Navigator.open`.

### `TripNavigationHost.java` (22 lines)
Interface used by trip screens to ask the shell to start/stop/return to navigation without knowing `MainActivity`. `MainActivity` implements it.

---

## `core/places` — 3 files

### `GeoapifyGeocoder.java` (192 lines)
Forward geocoding (address → lat/lng) and reverse geocoding (lat/lng → address) through Geoapify. Requests are restricted to India with `countrycode:in` (observed in the request builder), results are parsed by `GeoapifyPlaceParser`, and failures map to `error_address_lookup`. Used by `RegisterStationFragment` (address lookup), `RoutePlannerFragment` (origin/destination resolution), `PlaceSearchDialog`.

### `GeoapifyPlaceParser.java` (178 lines)
Parses Geoapify `features` into id/name/address/lat/lng suggestions, tolerating missing fields. Unit-tested in `GeoapifyPlaceParserTest`.

### `PlacesAutocomplete.java` (316 lines)
Debounced autocomplete controller: **300 ms** debounce, **minimum 3 characters**, **maximum 5** suggestions, stale responses dropped with `RequestSequence`. Exposes a callback and `cancel()`. Used by `PlaceSearchDialog` and the route planner's destination field.

---

## `core/routing` — 4 files

### `DirectionsRoute.java` (165 lines)
Route value object: distance, duration, duration-in-traffic, geometry points, provider, and `getDurationInTrafficMinutes()`. The method's documentation promises a fallback to normal duration when traffic data is absent, but the implementation returns `0` in that case (finding Q2). Consumers must therefore guard against zero; the planner uses its own 45 km/h estimate.

### `GeoapifyRoutingClient.java` (417 lines)
HTTP client for Geoapify routing. Builds the request (mode, waypoints, units, API key), parses distance/duration/geometry/steps, normalises provider errors through `GeoapifyErrors`, and caches with `RouteCache`. All calls pass through `RequestThrottle`. Unit-tested in `GeoapifyRoutingClientTest`.

### `RequestThrottle.java` (63 lines)
Token-bucket limiter allowing **4 starts per second** across routing calls. `tryAcquire()` returns false rather than blocking the caller; screens surface a retry message. Unit-tested indirectly through routing tests.

### `RouteCache.java` (87 lines)
In-memory LRU of **20** `DirectionsRoute` entries with a **10-minute** TTL, keyed by origin/destination/mode. Unit-tested in `RouteCacheTest`.

---

## `core/security` — 2 files

### `AuthManager.java` (172 lines)
Process-wide holder of the signed-in `User` and the **acting role**. `setCurrentUser`, `clearCurrentUser`, `getCurrentUser`, `getCurrentUserId`, `getCurrentRole`, `setRole(role)`, `roleLabel(role)`. `setRole` is the authority check: it refuses a role the user is not entitled to, and `MainActivity.applyRole` falls back to Consumer. The acting role is deliberately separate from `User.role` so an admin can act as a consumer without changing the database row. Not persisted; `MainActivity.restoreSession` rebuilds it.

### `RoleGuard.java` (53 lines)
Small policy helper answering whether a role may open a tab/action (host tabs, admin tabs, consumer tabs). Unit-tested in `RoleGuardTest`. `MainActivity` builds menus per role, so this is defence in depth rather than the primary gate.

---

## `core/state` — 3 files

### `AppStateStore.java` (274 lines)
The in-process shared state between phone and car. Observed API: singleton `get()`; `setUserId`; `reset`; battery (`getCurrentSoc`, `applyStoredSoc`, `isSocAuthoritative`, `applySocCorrection`); active trip (`getActivePlan`, `setActivePlan`); reservation (`getActiveReservation`, `setActiveReservation`, `setLastBookingCode`); safe-charger set (`safeReachableStations`); messages (`setLastRecalculationSummary`, `getNoSafeChargerMessage`, `setNoSafeChargerMessage`); car connection flag (`setCarConnected`); listener registration. It holds no database and no tokens. Unit-tested in `AppStateStoreTest`.

### `SocStore.java` (95 lines)
Persists the last user-confirmed battery percentage in `SharedPreferences`, keyed by **account id + vehicle id**, with a **12-hour** validity window. `load(context, userId, vehicleId)` is called by `MainActivity.onSignedIn`; a stale or different-vehicle value is discarded (`applyStoredSoc(vehicleId, -1)`), which prevents one car's reading following the driver to another profile.

### `TripSessionStore.java` (285 lines)
Persists the active trip across process death: plan id, origin/destination, label, progress percent and step index, last position, start/update timestamps, and a `hasActive(context)` flag read by `MainActivity.buildNavigation` to land on Trips instead of Discover. `end(context)` is called on sign-out (`MainActivity.onSignedOut`) so a trip never belongs to the next account. It is a file/prefs store, not a Room table; the authoritative plan itself stays in Room/Supabase.

---

## Cross-cutting constants observed in this area

| Constant | Value | Declared in | Used by |
|---|---|---|---|
| Average driving speed | 45 km/h | `GeoUtils.drivingMinutes` | planner ETA, SoC ETA |
| Trip-time speed | 60 km/h | `TripTimeEngine` | legacy trip estimate (inconsistent, Q1) |
| Routing throttle | 4 starts/s | `RequestThrottle` | `GeoapifyRoutingClient` |
| Route cache | 20 entries / 10 min | `RouteCache` | `GeoapifyRoutingClient` |
| Autocomplete | 300 ms / 3 chars / 5 results | `PlacesAutocomplete` | `PlaceSearchDialog`, planner |
| Geocode country | `countrycode:in` | `GeoapifyGeocoder` | all address lookups |
| SoC persistence | 12 h, per account+vehicle | `SocStore` | `MainActivity.onSignedIn` |
| SoC reserve default | 15 % | `SoCEstimatorEngine.DEFAULT_RESERVE_PERCENT` | planner, car snapshot |

Everything else in `core` is stateless or per-call. There is no DI container: `AmperlyRepository.getInstance(context)` and `AuthManager.getInstance()` are the two process singletons.
