# Amperly
### Smart Reservation and Management Platform for Existing EV Chargers

**Amperly** is an Android-first hyperlocal EV charger-management, route-planning, and reservation platform written in Java. It helps drivers plan a journey around compatible chargers that already exist, reserve a specific port, check in with a QR code, talk to the Host through masked channels, and pay only for **verified meter readings** — with a glanceable version of the same trip on the car display through **Android Auto**.

Google Maps helps you find a charger. **Amperly helps you reserve, access, use, and pay for it** — with route-aware charging plans projected onto the car display.

> Route energy and battery-drain figures are **planning estimates**. The final bill is always based on verified meter readings. Stations without a verified meter can only take a reservation **without automatic billing**.

---

## 1. What this build actually is

The MVP is a **single-process Android application**. There is no live backend and no charger hardware integration:

| Concern | How it works in this MVP |
|---|---|
| Persistence | Room database (`AmperlyDatabase`, **v2, 23 entities + 23 DAOs**), the single source of truth |
| Data access | One hub, `AmperlyRepository` (all DAO access, off-main-thread helpers) |
| Demo data | `PilotDataSeeder` seeds the controlled pilot on first launch |
| Maps | Google Maps panel when a key is configured, explanatory card + `geo:` intent handoff when it is not |
| Payments | `PaymentManager` sandbox: authorize → capture/refund/release, idempotency keys, offline failure path |
| Charger telemetry | None. Availability is schedule-, reservation- and host-update-based, and is labelled with a freshness timestamp |
| Meter data | `MeterSimulator` / manual entry, always labelled **Demo meter** or **manually entered** |
| Cloud | Optional Supabase/Postgres backend (`supabase/`). When `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY` are set it becomes the source of truth; when they are absent the app runs fully on-device. A trigger on `auth.users` gives every account its `public.users` profile — the row Row Level Security resolves the caller through |
| Sync | Room stays the read cache and the offline write queue: a `sync_outbox` table plus `SyncEngine` push local changes and pull everything changed on the server. Pushing is automatic — every local write schedules a coalesced push shortly after it — so a saved profile reaches the backend without the user pressing anything; the account screen's **Sync now** remains for a manual push/pull |

`AmperlyDatabase` uses `fallbackToDestructiveMigration()`, so a schema change resets local demo data instead of migrating it.

---

## 2. Architecture

```
┌──────────────────────────────────────────────────────────────────────┐
│                          MainActivity (role switch)                  │
│        Consumer tabs │ Host tabs │ Admin tabs  (ChipGroup of roles)   │
└───────────────┬──────────────────────────────────────────────────────┘
                │  fragments call engines directly (no ViewModels)
                ▼
┌──────────────────────────────────────────────────────────────────────┐
│                              Engines                                 │
│ Routing │ SoC │ Billing │ Availability │ Meter │ Booking │ Analytics  │
│                     Enforcement policy                                │
└───────────────┬──────────────────────────────────────────────────────┘
                │
┌───────────────▼──────────────────────────────────────────────────────┐
│                         AmperlyRepository                            │
│      stations · ports · schedules · reservations · sessions ·         │
│      meters · invoices · payments · reports · disputes · chat ·       │
│      safety · route plans · auto sessions   (Room, background IO)     │
└───────────────┬──────────────────────────────────────────────────────┘
                │
     ┌──────────┴───────────┐
     ▼                      ▼
┌──────────────┐   ┌──────────────────────────────────────────┐
│ AppStateStore│   │            Android Auto layer            │
│ shared trip  │◄──│ CarBridge · AmperlyCarSession · screens  │
│ + SoC state  │   │ RouteOverview · ChargerList · Details ·   │
└──────────────┘   │ SoCUpdate · ReservationStatus            │
                   └──────────────────────────────────────────┘
```

The phone and the car read the **same** `AppStateStore`, so a reservation or battery update made on one surface is visible on the other.

---

## 3. Engines and the guarantees they hold

| Engine | Responsibility and hard rules |
|---|---|
| `RoutePlannerEngine` | Corridor filtering, connector compatibility, detour cost, greedy multi-stop plan, backup stops before/after, recorded assumptions, HIGH/MEDIUM/LOW confidence. **Never routes beyond the safe range**: if nothing is reachable it returns a `noStopWarning` instead of an invented stop. Out-of-corridor and incompatible stations are returned as **explanations with reasons**, not silently dropped. |
| `SoCEstimatorEngine` | Estimates a starting SoC from the vehicle profile (always labelled an estimate) and applies the consumer's dashboard value as **authoritative**: keeps the old estimate for audit, removes unreachable chargers, adds newly reachable ones, recalculates the **remaining** trip, and reports a prominent **no safe charger** state with alternatives instead of a fake route. |
| `BillingEngine` | Blocks paid billing entirely at stations without a verified meter. Itemises starting/ending readings, verified kWh, energy charge, service fee, gateway fee and final total. Zero energy ⇒ zero charge. Unusually large readings are flagged for admin review. Also owns the cancellation policy and refund/adjustment maths. |
| `AvailabilityEngine` | Builds bookable slots from operating schedules, port status, maintenance blocks and existing reservations; detects conflicts; summarises openness. |
| `MeterSimulator` | Cumulative demo readings, session progression, offline state, invalid (reversed) readings and physically implausible readings. |
| `ReservationEngine` | Double-booking prevention, port-level connector compatibility, paused/unverified station rejection, meterless-station policy, price preview with authorized headroom, booking code and QR payload, and the published cancellation policy copy. |
| `HostAnalyticsEngine` | Utilisation, energy delivered, revenue, repeat consumers, cancellation rate, average session size, disputes and refunds — for one host or the whole platform. |
| `EnforcementPolicyEngine` | Evidence-based escalation: warning → fine → suspension → ban. An **unverified** accusation results in `NONE`; hosts are never punished on an unproven complaint. |

`PaymentManager` (sandbox authorize/capture/refund/release + idempotency) and `ChatManager` (number masking, text sanitising, off-platform payment detection, 7-day thread expiry) sit alongside the engines.

---

## 4. Honesty rules baked into the product

These are requirements, not niceties, and the code enforces them:

1. **Meter-first billing.** No verified meter ⇒ no automatic energy charge. Level 3 stations stay visible as *discovery only*.
2. **Estimates are labelled.** Route energy, SoC and arrival percentages are always presented as estimates; the UI shows when the battery figure was last updated.
3. **The consumer's battery value wins.** A dashboard SoC always overrides Amperly's estimate for the remaining trip.
4. **The original plan is never silently rewritten.** Screens show `Original estimate → Actual update → Revised recommendation`, and the audit record is stored.
5. **Simulated data says so.** Demo meter readings are labelled "Demo meter — simulated reading, not live charger hardware".
6. **No emergency-service claim.** The SOS screen offers trusted-contact live-location sharing (60 minutes, opt-in, cancellable) and points at local emergency numbers — it does not promise a response.
7. **Free-text chat is phone-only.** The car surface never offers typing.
8. **Freshness is visible.** "Availability last updated X ago" is shown wherever availability is presented.

---

## 5. Package structure (`com.amperly.app`)

```text
com.amperly.app/
├── AmperlyApplication.java, MainActivity.java
│
├── core/
│   ├── common/     AppConstants, Formatters, GeoUtils, PilotPlaces, ValidationUtils
│   ├── location/   LocationProvider
│   ├── map/        MapHelper, OsmTileMapView, Mercator, MapTiles
│   │                                    (OpenStreetMap tiles, no API key, no map SDK)
│   ├── nav/        Navigator            (fragment nav + geo:/tel: handoff)
│   ├── security/   AuthManager, RoleGuard
│   └── state/      AppStateStore        (shared phone ↔ car trip + SoC state)
│
├── data/
│   ├── local/      AmperlyDatabase (v3), PilotDataSeeder
│   │   ├── dao/    23 DAOs
│   │   ├── entity/ 23 entities (User, Vehicle, ChargerStation, ChargerPort,
│   │               AvailabilitySchedule, Reservation, ChargingSession,
│   │               MeterReading, Invoice, Payment, RoutePlan, RouteStop,
│   │               TripEstimate, BatteryUpdate, CommunicationThread,
│   │               ChatMessage, SafetyEvent, TrustedContact, Report, Dispute,
│   │               HostEnforcementAction, Notification, AndroidAutoSession)
│   └── repository/ AmperlyRepository            (single data hub)
│
├── domain/enums/   ChargerStatus, ConnectorType, MeterVerificationLevel,
│                   ReservationStatus, UserRole
│
├── engine/
│   ├── admin/        EnforcementPolicyEngine
│   ├── analytics/    HostAnalyticsEngine
│   ├── availability/ AvailabilityEngine
│   ├── billing/      BillingEngine
│   ├── booking/      ReservationEngine
│   ├── meter/        MeterSimulator
│   ├── routing/      RoutePlannerEngine, TripTimeEngine
│   └── soc/          SoCEstimatorEngine
│
├── feature/
│   ├── consumer/   ChargerDiscovery, ChargerDetails, RoutePlanner, VehicleProfile,
│   │               Reservation, BookingQr, ActiveSession, Receipt, SafetySOS,
│   │               HostChat
│   ├── host/       HostDashboard, RegisterStation
│   └── admin/      AdminDashboard
│
├── ui/             Ux, adapter/* (9 adapters), dialog/* (ReportDialog, MeterEvidenceDialog)
│
├── car/
│   ├── AmperlyCarAppService.java, AmperlyCarSession.java, CarBridge.java, CarScreenFactory.java
│   └── screen/     RouteOverview, ChargerList, ChargerDetails, SoCUpdate, ReservationStatus
│
├── payment/        PaymentManager
└── communication/  ChatManager
```

---

## 6. Build & run

### Prerequisites
- Android Studio (JDK 11+ sources; the Studio bundled JBR works).
- Android SDK Platform 35 (compile/target 35, min 24).

### Commands

```bash
# Unit tests (67 tests across 9 classes)
./gradlew :app:testDebugUnitTest

# Debug APK → app/build/outputs/apk/debug/app-debug.apk
./gradlew :app:assembleDebug

# Release APK → app/build/outputs/apk/release/app-release.apk
./gradlew :app:assembleRelease
```

### Release builds and signing

`assembleRelease` needs a keystore to produce an APK that anyone can install. Point Gradle at one
through `local.properties` (gitignored — the keystore and its passwords never enter the repository):

```properties
KEYSTORE_FILE=keystore/amperly-release.jks
KEYSTORE_PASSWORD=…
KEY_ALIAS=amperly
KEY_PASSWORD=…
```

The same four keys work as environment variables. With no keystore configured the release build still
succeeds, but it emits `app-release-unsigned.apk`, which no device will install — Gradle prints a
warning that says so.

Keep the keystore (and its passwords) somewhere you control and reuse it for every future release:
Android will only accept an update signed with the same key, so losing it means the only way forward
is a new application id.

On Windows, if `JAVA_HOME` is not set globally:

```bash
export JAVA_HOME="/c/Program Files/Android/Android Studio/jbr"
./gradlew :app:testDebugUnitTest --console=plain
```

### Maps — OpenStreetMap, no key of any kind

The embedded map is `core/map/OsmTileMapView`: OpenStreetMap raster tiles fetched with the app's
own OkHttp client, projected with Web Mercator (`core/map/Mercator`) and drawn on a `Canvas`. There
is no maps SDK, no API key, no Cloud project and no billing account to set up, and host-registered
chargers appear on it as soon as they are approved.

Tiles default to the public OpenStreetMap server. To use your own (recommended for anything beyond
a pilot), set an OSM-style URL template in `local.properties` or the environment:

```properties
OSM_TILE_URL=https://tiles.example.org/{z}/{x}/{y}.png
OSM_USER_AGENT=my-fleet-app/1.0 (ops@example.org)
```

`OSM_USER_AGENT` is optional and defaults to the application id and version. OpenStreetMap's tile
usage policy requires a User-Agent that identifies the application, so do not blank it.

Tiles are cached in memory and under `cache/osm-tiles` (64 MB cap, trimmed on a background thread
the first time a map panel is created), so a station list that has been opened once keeps working
without a connection. Turn-by-turn navigation is still
handed off to the phone's own maps application through a `geo:` intent.

### Routing — OSRM, no key of any kind

Directions to a charger are road-based, not straight lines: `core/routing/OsrmRouter` calls OSRM
(the Open Source Routing Machine) and draws the returned geometry on the same map. The public OSRM
demo server is the default and needs no account. Something else can be used by setting:

```properties
OSRM_BASE_URL=https://osrm.example.org
```

The routing screen offers **Driving** and **Walking**. The public demo server carries only the car
profile and answers a foot request with car geometry, so walking is shown as a clearly-labelled
straight-line estimate unless `OSRM_BASE_URL` points at a server with a foot profile — the app never
presents driving geometry as a walking route. When the routing service cannot be reached, the screen
falls back to the same labelled estimate instead of failing.

---

## 7. Pilot data (`PilotDataSeeder`)

Seeded once, on first launch:

**Users** — `user_campus_admin` (Host/Admin, ABC College), `user_student_1` (Consumer), `user_apt_association` (Host, GreenPark), `user_platform_admin` (platform Admin).
**Vehicle** — `veh_101`, Tata Nexon EV Max, CCS2 DC + 7.2 kW AC, 96% health.

**Stations**

| Station | Type | Connector / power | Meter level | Tariff |
|---|---|---|---|---|
| ABC College Campus Charger (Gate 2) | Campus, 08:00–20:00 | Type 2 AC 7.2 kW + CCS2 DC 30 kW, 4 ports | L1 verified manual | ₹18/kWh + ₹5 + ₹4 |
| GreenPark Shared Charger | Apartment, 24/7 | Type 2 AC 7.2 kW, 2 ports | L1 verified manual | ₹16/kWh + ₹5 + ₹4 |
| Highway Hub Charger | Commercial, 24/7 | CCS2 DC 60 kW + CHAdeMO, 2 ports | L2 simulated smart meter | ₹21/kWh + ₹6 + ₹4 |
| Kodagu Roadside Charger | Parking, 06:00–22:00 | Type 2 AC 7.2 kW | L1 verified manual | ₹15/kWh + ₹5 + ₹4 |
| Cafe ChargePoint | Café | Type 2 AC 3.3 kW | **L3 no verified meter** | discovery only, no billing |
| Tech Park Tower Charger | Office, **approval pending** | Type 2 AC 11 kW | L1 | appears in the admin queue |

Also seeded: full weekly availability schedules, two completed sessions with invoices + payments, one upcoming reservation **`AMP-2002`** with a payment authorization, one dispute, one report, one chat thread (with masked and off-platform messages), a trusted contact, a safety event, notifications, and a completed route plan with stops, a backup, a trip estimate, an auto session and a battery update.

---

## 8. Suggested demo script

Run the whole value chain, not just a map:

1. **Admin** → open the admin dashboard, approve **Tech Park Tower Charger** from the verification queue.
2. **Consumer** → set the vehicle profile (or use the seeded Nexon EV) and open **Discover**: filter by connector, price, availability and distance; the map plots compatible stations and the meter status of each.
3. **Consumer** → open **Route planner**, enter *Mysore → Mangalore* with the current battery. Show the corridor chargers, the detour/charge-time/arrival trade-off, the recommended stop plus **backup stops before and after**, the recorded assumptions, and the confidence level.
4. **Consumer** → in the same screen, enter a lower **actual dashboard SoC**. Show that the value becomes authoritative: unreachable chargers are removed, the remaining trip is recalculated, and the revised recommendation is explained. Then demonstrate the **no safe charger** state (drop the battery very low) — alternatives are offered instead of a route past the safe range.
5. **Consumer** → reserve a port on the campus charger: real free slots, port choice, price breakdown, cancellation policy, sandbox authorization, then the **booking QR code**.
6. **Host** → on the host dashboard, see the reservation, scan the booking code, start the session, and watch the demo meter record the starting reading.
7. **Consumer** → complete the session: end reading, verified kWh, itemised receipt (energy / service / gateway) and capture.
8. **Host** → show analytics: sessions, energy delivered, utilisation, revenue, cancellations, disputes.
9. **Consumer ↔ Host** → open the reservation chat: masked numbers, quick questions, and an off-platform payment attempt being flagged.
10. **Safety** → long-press SOS during an active session: trusted contacts, 60-minute live-location sharing, and the clear "Amperly is not an emergency service" guidance.
11. **Consumer** → file a report from the receipt; **Admin** → review the evidence, refund, and action the host. Show that an *unverified* accusation produces no enforcement.
12. **Car** → launch the Android Auto service (Desktop Head Unit or a real head unit): route overview, charger list, single-tap reservation of the next free slot, and the large **Update battery** action that recalculates from shared state.

---

## 9. Tests

```bash
./gradlew :app:testDebugUnitTest    # 67 tests, all green
```

| Class | Covers |
|---|---|
| `EngineUnitTest` | Corridor filtering and exclusion reasons, trade-off explanation + backup stop, no-stop-needed at full battery, SoC override authority, no-safe-charger state, relaxed-reserve alternative, meter-only billing, invalid/unverified meter rejection, zero-energy rule, geo helpers, port labels |
| `BookingAndMeterTest` | Free slot booking, double-booking prevention, **port-level** connector rejection, paused/pending station rejection, meterless reservation policy, price preview, published cancellation policy, free-cancellation window, meter simulator progression/implausible readings/offline state, itemised receipt lines |
| `AvailabilityEngineTest` | Slot generation from schedules, ports, blocks and reservations; conflicts; summaries |
| `EnforcementPolicyTest` | Warning → fine → suspension → ban escalation, and no action on unverified accusations |
| `PaymentManagerTest` | Authorization, idempotency, capture, refund, release, gateway-offline failure |
| `ChatManagerTest` | Number masking, sanitising, off-platform detection, thread open/expiry rules, quick questions, audit fields |
| `RoleGuardTest` | Consumer / Host / Admin permission boundaries, including the dual-role account that is both |
| `MercatorTest` | Web Mercator projection used by the OpenStreetMap tile view: round-trips, scale, zoom clamping, tile maths |
| `UserProfileRowTest` | The `public.users` profile row and the `auth.users` trigger that creates it, checked against `supabase/schema.sql`, so profile creation cannot silently regress |

---

## 10. Technology stack

| Layer | Technology |
|---|---|
| Language / IDE | Java 11 source level, Android Studio, Gradle 9 + AGP 9 |
| Compile/target SDK | 35 (minSdk 24) |
| UI | Material 3 components, `viewBinding`, RecyclerView, custom `Widget.Amperly.*` styles + `values-night` theme |
| Car UI | Android for Cars App Library (`androidx.car.app:app:1.4.0`), Charging + Navigation categories |
| Persistence | Room (`room-runtime 2.6.1`) — 23 entities, 24 DAOs (incl. the sync outbox) |
| Backend (optional) | Supabase — Postgres with Row Level Security, PostgREST data API and GoTrue auth, over Retrofit/OkHttp. See [`supabase/README.md`](supabase/README.md) |
| Maps & location | OpenStreetMap raster tiles drawn in-app (`core/map`, no SDK and no API key) + `play-services-location` for the position fix |
| Routing | OSRM (`core/routing`, public demo server by default, no key); driving road routes, walking shown as a labelled estimate unless a foot-profile server is configured |
| QR codes | ZXing `core` (bitmap generated in-app) |
| Payments | In-repo sandbox `PaymentManager` (no card data is ever stored) |
| Tests | JUnit 4 (unit tests, no device required) |

---

## 11. Explicitly out of scope for this MVP

No new charger installation; no remote charger control; no connector API or OCPP; no vehicle-to-vehicle sharing; no private-home chargers; no bidding for slots; no time-based energy estimation; no paid billing without a verified meter; no claim that estimates are measurements; no guarantee of reachability; no emergency-service guarantee; Android Automotive OS (installed-in-car) is a **future** target — this build targets **Android Auto projection**.

---

## 12. License & attribution

Amperly is developed as an open EV charger management platform.
