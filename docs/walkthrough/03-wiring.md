# 03 — Wiring: how every layer connects

This is the call graph, written from the code rather than from the README. Arrows mean "calls/reads"; no arrow means there is no dependency.

---

## 1. Process-level objects

```
AmperlyApplication            DOES NOT EXIST (README drift, Q4)
MainActivity                  the only Activity; owns the shell
  ├── AmperlyRepository.getInstance(context)      singleton, Room + PostgREST
  ├── AuthManager.getInstance()                   signed-in User + acting role (memory)
  ├── AppStateStore.get()                         phone↔car state (memory)
  ├── SupabaseAuth                                session tokens (EncryptedSharedPreferences)
  └── SyncEngine.syncNow(context, db)             pull/push after sign-in
```

`AmperlyCarAppService` is a second Android entry point in the same process. It constructs the same `AmperlyRepository` and reads the same `AppStateStore`/`AuthManager`; it has no independent state.

---

## 2. Activity → navigation → fragments

```
onCreate
 ├─ setContentView(activity_main)
 ├─ applyWindowInsets / applyKeyboardInsets
 ├─ restoreTabs(savedState)            currentTabTag, tabTags, savedTabStacks
 ├─ startBackend
 │   ├─ SupabaseConfig invalid/secret → showSignIn
 │   ├─ SupabaseAuth.hasStoredSession → restoreSession
 │   │    └─ SupabaseAuth.restoreSession → repo.resolveOrCreateAppUser
 │   │         → repo.accountRestrictionMessage → onSignedIn
 │   └─ else showSignIn
 └─ handleDeepLink(amperly://auth-callback) → toast only

onSignedIn
 ├─ AuthManager.setCurrentUser
 ├─ repo.getVehicleSync → SocStore.load → AppStateStore.applyStoredSoc
 ├─ setNavWanted(true) / setChromeVisible(true)
 ├─ applyRole(ADMIN|CONSUMER) → AuthManager.setRole → buildNavigation
 └─ syncAfterSignIn → maybe clearLocalData → SyncEngine.syncNow → rebuild current tab
```

`buildNavigation(role, initialItemId)` clears the `BottomNavigationView` menu and adds items with the ids in `values/ids.xml`. The selection listener routes to `loadConsumerScreen` / `loadHostScreen` / `loadAdminScreen`, each of which calls `loadRoot(fragment, tabTag)`.

Tab roots:

| Role | Tab id | Root fragment | Tag |
|---|---|---|---|
| Consumer | `nav_discover` | `ChargerDiscoveryFragment` | `discover` |
| Consumer | `nav_route_plan` | `RoutePlannerFragment`, or `InAppNavigationFragment.forActiveTrip` when a trip runs | `route` |
| Consumer | `nav_reserve` | `ReservationFragment` | `reserve` |
| Consumer/Host | `nav_profile` | `AccountFragment` | `account` |
| Host | `nav_host_dashboard` | `HostDashboardFragment` | `host_home` |
| Host | `nav_host_add_station` | `HostStationsFragment` | `register` |
| Host | `nav_host_bookings` | `HostBookingsFragment` | `host_bookings` |
| Admin | `nav_admin_queue` | `AdminDashboardFragment(SECTION_QUEUE)` | `admin_queue` |
| Admin | `nav_admin_reports` | `AdminDashboardFragment(SECTION_REPORTS)` | `admin_reports` |

`Navigator.open(fragment, tag)` adds a page to the current tab's back stack; `Navigator.openRoot` replaces the container for root pages (`account_page`, `vehicle`, `safety`, `notifications`). `MainActivity.leaveCurrentTab` files pages under the tab name (`saveBackStack`) and `openTripsTab`/`loadRoot` restore them, so tabs are never destroyed on switch.

Back: `handleBack` → fragment stack → home (`finish`) → `goHome` (select role home tab). Re-tapping the active tab calls `popCurrentTabPages` (discard, not file).

---

## 3. Screen → repository → Room/Supabase

The uniform read path:

```
Fragment
  → repo.background(() -> repo.getXSync(...), value -> render(value))
      → Room DAO (cache)
      → (on miss / after sign-in) SyncEngine pull
```

The uniform write path:

```
Fragment → repo.saveX(...) / repo.createX(...)
  1. validate locally (engines/ValidationUtils)
  2. Room insert/update (cache)
  3. PostgREST insert/patch/delete with the bearer token
  4. callback(result) → toast/error; local row remains if the server refuses
```

Exceptions where the server must write first:

| Action | Call | Why |
|---|---|---|
| Create reservation | `create_reservation` RPC | per-port advisory lock; only INSERT path into `reservations` |
| Cancel reservation | `cancel_reservation` RPC | server applies the late fee and releases holds |
| Finalize session / bill | `finalize_charging_session` RPC | recomputes kWh and amounts; writes invoice |
| Approve/reject station | `decide_station_approval` RPC | admin-only; host cannot self-approve |
| Resolve dispute | `resolve_dispute_refund` RPC | refund + invoice + dispute in one transaction |
| Freeze payout | `freeze_dispute_payout` RPC | admin-only |
| Enforce host | `apply_host_enforcement` RPC | records action and pauses station |

`SupabaseRest` is the only HTTP layer; `SupabaseClient` attaches `apikey` and `Authorization`; `SupabaseAuth` supplies/refreshes the token; `SupabaseApi` holds paths/RPC names.

---

## 4. Sync wiring

```
MainActivity.syncAfterSignIn
  → if account changed: repo.clearLocalData()
  → repo.database().userDao().insert(currentUser)
  → SyncEngine.syncNow(context, db)
       pull: for each SyncTables entry → SupabaseRest.select(updated > cursor, limit 500)
             → Room REPLACE; cursor = max serverUpdatedAt; max 20 pages
       ids:  select(id) → SyncReconciler.diff(local, remote) → delete missing
             (skipped if id pages hit the 40-page guard)
       push: local rows for writable tables → PostgREST upsert/patch/delete
       deletes: raw SQL dirty markers
  → callback(result) → rebuild current tab
```

`SyncTables` is the declarative list that makes the loop generic. `SyncReconciler` is a pure diff so the delete path can be tested without a server.

---

## 5. Map / places / routing wiring

```
MapPanel
  ├─ MapConfig (style URL, API key)
  ├─ StationMarkerModel + StationVisibility (what to draw)
  └─ MapLibre MapView (phone only)

PlaceSearchDialog / RoutePlannerFragment / RegisterStationFragment
  └─ PlacesAutocomplete (300 ms, ≥3 chars, ≤5)
       └─ GeoapifyGeocoder → GeoapifyPlaceParser
            └─ GeoapifyErrors → UserMessages

RoutePlannerFragment / InAppNavigationFragment
  ├─ GeoapifyRoutingClient (RequestThrottle 4/s, RouteCache 20/10 min)
  │    └─ DirectionsRoute
  └─ RoutePlannerEngine (corridor, greedy stops, backups, confidence, 45 km/h)
       └─ RoutePlan + RouteStop entities → repo

CarMap
  └─ Geoapify Static Maps (osm-bright) painted into the car Surface
```

`RouteProgress` and `NavigationState` sit between the route and the navigation UI; `NavigationProvider`/`GeoapifyNavigationProvider` adapt the routing client for turn-by-turn.

---

## 6. Battery/SoC wiring

```
SocStore (12 h, per user+vehicle) ──► MainActivity.onSignedIn ──► AppStateStore.applyStoredSoc

ChargerDiscoveryFragment battery dialog
  └─ SoCEstimatorEngine.applyAuthoritativeSocOverride
       ├─ safe / unreachable / newly reachable stations
       ├─ remaining distance + journey time (45 km/h)
       ├─ BatteryUpdate audit → repo.saveBatteryUpdate
       └─ AppStateStore.applySocCorrection / setLastRecalculationSummary
            / setNoSafeChargerMessage / safeReachableStations

CarBridge.applyBatteryUpdate
  └─ same engine, origin = plan origin, remaining = 60 % of total
       └─ same BatteryUpdate + AppStateStore updates
```

`CarBridge.load` reads `AppStateStore.getActivePlan()` first, falling back to `repo.getActiveRoutePlanSync`, then computes reachable stations with `SoCEstimatorEngine.safeAlternatives` for the car snapshot.

---

## 7. Booking / session wiring

```
ChargerDetailsFragment → ReservationFragment
  └─ repo.getSlots(stationId, start, DEFAULT_SLOT_MINUTES, 12)  [AvailabilityEngine]
  └─ repo.createReservationConfirmed(id, code, station, port, start, end)
       └─ POST rpc/create_reservation
            ├─ success → BookingResult(reservation) → BookingQrFragment
            └─ refusal → strings reserve_slot_taken / _in_past / _too_long /
                          _station_unavailable / _server_required / _server_failed

BookingQrFragment → ActiveSessionFragment
  └─ check-in → start → MeterEvidenceDialog/MeterSimulator
       └─ stop-and-bill → rpc/finalize_charging_session
            ├─ success → ReceiptFragment (server amounts)
            └─ failure → session_server_required / session_server_failed (no receipt)
```

The car's `reserveNextFreeSlot` enters the same booking path (RPC) without any payment UI.

---

## 8. Chat / safety / notifications

```
HostChatFragment
  └─ ChatManager → CommunicationThread (masked numbers, expiry, blocked/reported)
       └─ ChatMessage rows → repo → Supabase

SafetySOSFragment
  └─ TrustedContact CRUD + SafetyEvent (live-location flag, expiry)
       (no emergency-services call in code)

NotificationsFragment
  └─ Notification rows (bell / Account page)
```

---

## 9. Car wiring

```
AmperlyCarAppService
  └─ AmperlyCarSession
       ├─ AppStateStore.setCarConnected(true)
       ├─ saveAutoSession(connecting row)
       ├─ RouteOverviewCarScreen
       │    ├─ CarBridge.load → Snapshot
       │    ├─ CarMap (Geoapify static map → Surface)
       │    └─ pushes: ChargerList / ChargerDetails / SoCUpdate /
       │              ReservationStatus / TripHistory / Vehicle / CarSettings /
       │              Navigation
       └─ ON_DESTROY → saveAutoSession(disconnected), carConnected=false
```

---

## 10. Wiring that does **not** exist

- No `Application` subclass; no startup initialiser.
- No DI (Hilt/Dagger/Koin); singletons are static `getInstance`.
- No ViewModel/LiveData observation from fragments; no Navigation component/Safe Args.
- No WorkManager/JobScheduler; sync runs only when `MainActivity` calls it.
- No offline write queue; no retry worker.
- No OCPP/hardware/charger telemetry; `MeterSimulator` is the only meter.
- No payment gateway SDK/network charge.
- No push notifications/FCM; the inbox is a Room table pulled by sync.
- No Google Maps/Navigation SDK despite comments and the Maps migration note.
