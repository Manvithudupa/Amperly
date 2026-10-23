# Amperly
### Smart Reservation and Management Platform for Existing EV Chargers

**Amperly** is an Android-first hyperlocal EV charger-management, route-planning, and reservation platform written in Java. It helps drivers plan a journey around compatible chargers that already exist, reserve a specific port, check in with a QR code, talk to the Host through masked channels, and pay only for **verified meter readings** — with a glanceable version of the same trip on the car display through **Android Auto**.

Google Maps powers the map, the destination search and the route. **Amperly helps you reserve, access, use, and pay for the charger** — with route-aware charging plans projected onto the car display.

> Route energy and battery-drain figures are **planning estimates**. The final bill is always based on verified meter readings. Stations without a verified meter can only take a reservation **without automatic billing**.

---

## 1. What this build actually is

The MVP is a **single-process Android application**. There is no live backend and no charger hardware integration:

| Concern | How it works in this MVP |
|---|---|
| Persistence | Room database (`AmperlyDatabase`, **v4, 23 entities + 23 DAOs**), the single source of truth |
| Data access | One hub, `AmperlyRepository` (all DAO access, off-main-thread helpers) |
| Data source | **Supabase is the only source of truth.** No pilot seeding and no offline demo identity: stations, vehicles, reservations and readings are rows the signed-in account is authorised to read through Row Level Security. When the account has no rows, the screens say so instead of inventing content |
| Maps & navigation | **Google Maps SDK for Android** for the map, user-registered charger markers and in-app navigation; **Google Directions API** for road routes and turn-by-turn; **Google Place autocomplete** for destination and address entry. A missing key shows an actionable setup notice instead of a blank map. See §6 |
| Payments | `PaymentManager` sandbox: authorize → capture/refund/release, idempotency keys, offline failure path |
| Charger telemetry | None. Availability is schedule-, reservation- and host-update-based, and is labelled with a freshness timestamp |
| Meter data | `MeterSimulator` / manual entry, always labelled **Demo meter** or **manually entered** |
| Cloud | Supabase/Postgres backend (`supabase/`), the source of truth. When `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY` are set every screen reads and writes it; when they are absent `SyncEngine.isEnabled()` is false, nothing is pushed, and the app can only show what is already in the local Room cache. A trigger on `auth.users` gives every account its `public.users` profile — the row Row Level Security resolves the caller through |
| Sync | Room is the read cache only. Every save is written straight to Supabase by `SyncEngine` in the same task, so there is no outbox to drain and no manual sync control; `SyncEngine.syncNow` pulls rows changed since a per-table cursor so server-side and other-device changes appear in the app |

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
                │                        ┌───────────────────────────┐
                │                        │  NavigationProvider       │
                │                        │  GoogleNavigationProvider │
                │                        │  (Directions + Maps SDK)  │
                │                        └───────────────────────────┘
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
│ + SoC state  │   │ RouteOverview · Navigation · ChargerList ·│
└──────────────┘   │ Details · SoCUpdate · ReservationStatus · │
                   │ TripHistory · Vehicle · CarSettings       │
                   └──────────────────────────────────────────┘
```

The phone and the car read the **same** `AppStateStore`, so a reservation or battery update made on one surface is visible on the other.

---

## 3. Engines and the guarantees they hold

| Engine | Responsibility and hard rules |
|---|---|
| `RoutePlannerEngine` | Corridor filtering, connector compatibility, detour cost, greedy multi-stop plan, backup stops before/after, recorded assumptions, HIGH/MEDIUM/LOW confidence. Uses **Google's measured, traffic-aware drive time** when the routing provider supplies it, and falls back to a labelled average-speed estimate only when it does not. **Never routes beyond the safe range**: if nothing is reachable it returns a `noStopWarning` instead of an invented stop. Out-of-corridor and incompatible stations are returned as **explanations with reasons**, not silently dropped. |
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
3. **The consumer's battery value wins.** A dashboard SoC always overrides Amperly's estimate for the remaining trip, and the remaining route plus every charger recommendation is recalculated from the driver's real position.
4. **The original plan is never silently rewritten.** Screens show `Original estimate → Actual update → Revised recommendation`, and the audit record is stored.
5. **Simulated data says so.** Demo meter readings are labelled "Demo meter — simulated reading, not live charger hardware".
6. **No emergency-service claim.** The SOS screen offers trusted-contact live-location sharing (60 minutes, opt-in, cancellable) and points at local emergency numbers — it does not promise a response.
7. **Free-text chat is phone-only.** The car surface never offers typing.
8. **Freshness is visible.** "Availability last updated X ago" is shown wherever availability is presented.
9. **The start is the real position.** The route planner takes the device's current location as the origin; it never quietly substitutes a pilot coordinate. When there is no fix the screen says so and offers an explicit map-pin origin.
10. **No external handoff for in-app navigation.** Navigating to a charger stays inside Amperly on the Google map.

---

## 5. Package structure (`com.amperly.app`)

```text
com.amperly.app/
├── AmperlyApplication.java, MainActivity.java
│
├── core/
│   ├── common/     AppConstants, Formatters, GeoUtils, GoogleConfig, ValidationUtils,
│   │               UserMessages (one place that turns failures into plain language)
│   ├── location/   LocationProvider
│   ├── map/        MapPanel, MapContainerView, StationMarkerModel, StationVisibility
│   │                                    (Google Maps SDK renderer + marker rules)
│   ├── places/     PlacesAutocomplete, GoogleGeocoder  (Place autocomplete + Geocoding API)
│   ├── routing/    GoogleDirectionsClient, DirectionsRoute, Polyline
│   ├── nav/        Navigator, NavigationProvider, GoogleNavigationProvider,
│   │               NavigationState, RouteProgress
│   ├── security/   AuthManager, RoleGuard
│   └── state/      AppStateStore, SocStore   (shared phone ↔ car trip + SoC state)
│
├── data/
│   ├── local/      AmperlyDatabase (v4)
│   │   ├── dao/    23 DAOs
│   │   ├── entity/ 23 entities (User, Vehicle, ChargerStation, ChargerPort,
│   │               AvailabilitySchedule, Reservation, ChargingSession,
│   │               MeterReading, Invoice, Payment, RoutePlan, RouteStop,
│   │               TripEstimate, BatteryUpdate, CommunicationThread,
│   │               ChatMessage, SafetyEvent, TrustedContact, Report, Dispute,
│   │               HostEnforcementAction, Notification, AndroidAutoSession)
│   ├── remote/     SyncEngine, SyncTables, SupabaseClient, SupabaseApi,
│   │               SupabaseAuth, SupabaseConfig, SupabaseRest
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
│   ├── consumer/   ChargerDiscovery, ChargerDetails, InAppNavigation, RoutePlanner,
│   │               VehicleProfile, Reservation, BookingQr, ActiveSession, Receipt,
│   │               SafetySOS, HostChat
│   ├── auth/       SignIn, Account
│   ├── common/     Notifications
│   ├── host/       HostDashboard, RegisterStation
│   └── admin/      AdminDashboard
│
├── ui/             Ux, adapter/* (10 adapters), dialog/* (ReportDialog, MeterEvidenceDialog)
│
├── car/
│   ├── AmperlyCarAppService.java, AmperlyCarSession.java, CarBridge.java, CarScreenFactory.java
│   └── screen/     RouteOverviewCarScreen, NavigationCarScreen, ChargerListCarScreen,
│                   ChargerDetailsCarScreen, SoCUpdateCarScreen,
│                   ReservationStatusCarScreen, TripHistoryCarScreen, VehicleCarScreen,
│                   CarSettingsScreen
│
├── payment/        PaymentManager
└── communication/  ChatManager
```

---

## 6. Build & run

### Prerequisites
- Android Studio (JDK 11+ sources; the Studio bundled JBR works).
- Android SDK Platform 35 (compile/target 35, min 24).
- A **Google Cloud project with billing enabled** (see §6.1).

### Commands

```bash
# Unit tests
./gradlew :app:testDebugUnitTest

# Lint
./gradlew :app:lintDebug

# Debug APK → app/build/outputs/apk/debug/app-debug.apk
./gradlew :app:assembleDebug

# Release APK → app/build/outputs/apk/release/app-release.apk
./gradlew :app:assembleRelease

# Everything the migration asks for
./gradlew clean testDebugUnitTest lintDebug assembleDebug
```

On Windows, if `JAVA_HOME` is not set globally:

```bash
export JAVA_HOME="/c/Program Files/Android/Android Studio/jbr"
./gradlew :app:testDebugUnitTest --console=plain
```

### 6.1 Google Maps Platform setup (required for the map and routing)

The map, the destination search and the road routes all come from Google. Set **one key** in
`local.properties` (gitignored — it never enters version control):

```properties
GOOGLE_MAPS_API_KEY=your_key_here
```

`app/build.gradle.kts` injects that value two ways, so it is never written into Java or XML by hand:

- `buildConfigField("String", "GOOGLE_MAPS_API_KEY", …)` for the in-app Directions and Geocoding calls, and
- the `googleMapsApiKey` **manifest placeholder** for the Maps SDK `com.google.android.geo.API_KEY` meta-data.

When the key is absent the build prints a warning and every map screen shows an actionable setup
notice instead of a blank map — the app never silently pretends the map works.

**In the Google Cloud project, enable:**
1. **Maps SDK for Android**
2. **Places API** (Place autocomplete for the destination and host address fields)
3. **Directions API** (road routes, traffic-aware time, turn-by-turn steps)
4. **Geocoding API** (reverse-geocoding a host's map tap into a readable address)

**Restrict the key** (APIs & Services → Credentials → Application restrictions → Android apps):
- Add one entry per signing certificate: the package name `com.amperly.app` plus the **SHA-1** of
  the debug keystore (and separately the release keystore). Get them with:
  ```bash
  ./gradlew :app:signingReport            # debug/release SHA-1 fingerprints
  ```
- Under **API restrictions**, allow only the four APIs listed above.
- Use a **separate key** (or a separate Cloud project) for debug and release where you can, so a
  leaked debug key can be rotated without touching production.

Never ship a service-role key, a payment private key, or an unrestricted "any API" key in the app.

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

### Maps and navigation — Google Maps Platform

| Responsibility | Google service | Where |
|---|---|---|
| Base map, markers, route drawing | Maps SDK for Android | `core/map/MapPanel` |
| Destination and host-address search | Places SDK for Android | `core/places/PlacesAutocomplete` |
| Map tap → readable address | Geocoding API | `core/places/GoogleGeocoder` |
| Road route, distance, traffic time, turn-by-turn | Directions API | `core/routing/GoogleDirectionsClient` |
| In-app navigation session | `NavigationProvider` / `GoogleNavigationProvider` | `core/nav` |
| Android Auto driver-safe screen | Android for Cars App Library navigation template | `car/screen/NavigationCarScreen` |

Marker visibility is a product rule, not a rendering detail: **only approved, non-paused, non-banned
stations with real coordinates** are drawn (`core/map/StationVisibility`), and the meter status is
written into the marker text, so colour is never the only signal.

### Routing

Directions to a charger are road-based. `core/routing/GoogleDirectionsClient` calls the Google
Directions API and returns the road geometry, a traffic-aware duration and the ordered turn-by-turn
steps, which the route screen lists and the in-app navigation screen drives. The routing screen
offers **Driving** and **Walking**. When the key is missing or Google is unreachable, the screen says
so and — only where coordinates are known — falls back to a **clearly labelled straight-line
estimate**, never presenting it as a road route.

### Voice guidance and the Navigation SDK

Spoken turn-by-turn guidance, `NavigationViewForAuto` and the licence-gated parts of the Google
**Navigation SDK for Android** require an entitlement from Google that cannot be configured from this
repository. Amperly's navigation layer is written against the `NavigationProvider` interface and the
audio-guidance flags (`GoogleNavigationProvider.AUDIO_VOICE_ALERTS_AND_GUIDANCE`,
`AUDIO_BLUETOOTH`) are already modelled, so the licensed SDK can be dropped in behind the same
interface. See `GOOGLE_NAVIGATION_MIGRATION.md` for the exact seam.

---

## 7. Data model and the optional server-side demo seed

The app itself ships with **no demo data**. On first launch it shows the sign-in screen, and every
screen after that reads the signed-in account's own rows from Supabase (Room is only the read
cache; saves are written straight to the database). Sign-up creates the `public.users` profile row through the `auth.users`
trigger, so a brand-new account starts with empty lists and honest empty states.

For local demonstrations only, `supabase/pilot_seed.sql` can be run **against the database** to
insert the sample network below. It is a SQL script, not application code: nothing in the APK
creates these rows, and skipping it is the normal case.

**Users** — `user_campus_admin` (Host/Admin, ABC College), `user_student_1` (Consumer), `user_apt_association` (Host, GreenPark), `user_platform_admin` (platform Admin).
**Vehicle** — `veh_101`, Tata Nexon EV Max, CCS2 DC + 7.2 kW AC, 96% health.

Link the seed's auth users to the project with `supabase/link_pilot_users.sql` before signing in as
one of them.

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

1. **Admin** → approve **Tech Park Tower Charger** from the verification queue; it becomes a public marker on the Google map.
2. **Consumer** → set the vehicle profile (or use the seeded Nexon EV) and open **Discover**: the Google map centres on your real position and plots every approved, compatible charger.
3. **Consumer** → open **Route planner**. The start is already your current location; type a destination and pick it from **Google Place autocomplete**. Enter your battery %. Google supplies the road distance, the traffic-aware drive time and the **turn-by-turn directions** listed under the summary.
4. **Consumer** → see the corridor chargers, the detour/charge-time/arrival trade-off, the recommended stop plus **backup stops before and after**, the recorded assumptions, and the confidence level.
5. **Consumer** → enter a lower **actual dashboard SoC**. The value becomes authoritative: unreachable chargers are removed, the remaining trip is recalculated, and the revised recommendation is explained. Drop the battery very low to demonstrate the **no safe charger** state — alternatives are offered instead of a route past the safe range.
6. **Consumer** → tap **Start in-app navigation** for the Google-map navigation screen, then reserve a port and scan the **booking QR code**.
7. **Car** → launch the Android Auto service (Desktop Head Unit or a real head unit): route overview, the driver-safe **navigation** screen, and the large **Update battery** action that recalculates from shared state.

---

## 9. Tests

```bash
./gradlew :app:testDebugUnitTest    # 114 tests, all green
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
| `PolylineTest` | The Google encoded-polyline decoder against the canonical example |
| `GoogleDirectionsClientTest` | Directions parsing: metres/seconds, traffic-duration preference, HTML stripping, geometry order, denied/zero-result/no-geometry failures, the labelled straight-line fallback |
| `GoogleNavigationProviderTest` | Navigation session lifecycle: idle, start, progress, reroute, arrival, stop — against the production provider, no network |
| `RouteProgressTest` | Fraction along the route, remaining distance/time, next-maneuver selection |
| `RoutePlannerGoogleTimeTest` | Google's measured drive time overrides the average-speed estimate; total journey maths |
| `StationVisibilityTest` | Approved/pending/rejected/paused station visibility and coordinate validity |
| `StationMarkerModelTest` | Marker styling and the honest no-verified-meter / verified-meter wording; no host contact details leak |
| `HostAnalyticsEngineTest` | Revenue, refunds, energy, repeat consumers, cancellation rate and utilization on hand-built lists, plus the empty case |
| `TripTimeEngineTest` | Drive + detour + charging minutes, the total, zero distance and minute rounding |
| `UserProfileRowTest` | The `public.users` profile row and the `auth.users` trigger that creates it, checked against `supabase/schema.sql` |
| `SettlementFunctionContractTest` | The settlement SQL functions against the documented contract |

---

## 10. Technology stack

| Layer | Technology |
|---|---|
| Language / IDE | Java 11 source level, Android Studio, Gradle 9 + AGP 9 |
| Compile/target SDK | 35 (minSdk 24) |
| UI | Material 3 components, XML layouts with `findViewById`, RecyclerView, custom `Widget.Amperly.*` styles + `values-night` theme |
| Car UI | Android for Cars App Library (`androidx.car.app:app:1.4.0`), Charging + Navigation categories, navigation template |
| Persistence | Room (`room-runtime 2.6.1`, schema v4) — 23 entities, 23 DAOs; local read cache only, with no offline write queue |
| Backend (optional) | Supabase — Postgres with Row Level Security, PostgREST data API and GoTrue auth, over Retrofit/OkHttp. See [`supabase/README.md`](supabase/README.md) |
| Maps | **Google Maps SDK for Android** (`play-services-maps`) |
| Places | **Google Places SDK for Android** (`places`) + Geocoding API |
| Location | `play-services-location` fused provider for the real position |
| Routing | **Google Directions API** (traffic-aware), behind the `NavigationProvider` interface |
| QR codes | ZXing `core` (bitmap generated in-app) |
| Payments | In-repo sandbox `PaymentManager` (no card data is ever stored) |
| Tests | JUnit 4 (unit tests, no device required) |

---

## 11. Explicitly out of scope for this MVP

No new charger installation; no remote charger control; no connector API or OCPP; no vehicle-to-vehicle sharing; no private-home chargers; no bidding for slots; no time-based energy estimation; no paid billing without a verified meter; no claim that estimates are measurements; no guarantee of reachability; no emergency-service guarantee; **no silent use of a pilot coordinate as the user's location**. The licence-gated Google **Navigation SDK** (spoken guidance, `NavigationViewForAuto`) is integrated behind an interface but not enabled; Android Automotive OS (installed-in-car) is a **future** target — this build targets **Android Auto projection**.

---

## 12. License & attribution

Amperly is developed as an open EV charger management platform. Map data and routing © Google.
