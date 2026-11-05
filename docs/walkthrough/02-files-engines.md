# 02 — Files: `engine/`, `domain/`, `payment/`, `communication/` (16 files)

All engine classes are pure Java (no Android/network), which is why they carry most of the unit tests. Method lines: `09-symbol-index.md`.

---

## `domain/enums` — 5 files

| File | Values | Consumers |
|---|---|---|
| `UserRole.java` (7) | CONSUMER, HOST, ADMIN | `AuthManager`, `RoleGuard`; `AppConstants` holds the string form |
| `ReservationStatus.java` (10) | RESERVED, CHECKED_IN, CHARGING, COMPLETED, CANCELLED, EXPIRED, DISPUTED, REFUNDED | `Reservation.isActive()`, adapters, `HostAnalyticsEngine` |
| `ChargerStatus.java` (7) | AVAILABLE, OCCUPIED, MAINTENANCE, RESERVED | `ChargerPort`, availability timeline |
| `ConnectorType.java` (8) | TYPE_2_AC, CCS_2_DC, CHADEMO (and the parser's accepted aliases) | vehicle/station compatibility, connector icons |
| `MeterVerificationLevel.java` (7) | LEVEL_1_VERIFIED_MANUAL, LEVEL_2_SIMULATED_SMART_METER, LEVEL_3_NO_VERIFIED_METER | billing gate, station badge, seeded default |

The enums are the canonical spelling; the database stores the same strings.

---

## `engine/availability/AvailabilityEngine.java` (271 lines)

Builds bookable slots for a port/day from `AvailabilitySchedule` (open/close minutes, `isBlocked`) minus live reservations and port status. Public surface observed through callers:

- `DEFAULT_SLOT_MINUTES` — used by `CarBridge.reserveNextFreeSlot` when asking for 12 slots.
- `Slot` — `getStartMs()`, `getEndMs()`, `getPortId()`, `getPortLabel()`, `isAvailable()`.
- `getSlots`/`buildSlots` — returns consecutive slots for a window, marking a slot unavailable when it overlaps a reservation or the port is not `AVAILABLE`.

Server-side authority: the UI may show a slot as free, but `create_reservation` re-checks under a per-port advisory lock; the server's refusal is what the user sees. Unit-tested in `AvailabilityEngineTest` (slot boundaries, blocked days, overlapping reservations, past slots).

---

## `engine/booking/ReservationEngine.java` (167 lines)

Reservation rules that do not need the database:

- `buildBookingCode()` — `"AMP-"` + 6 characters from a 31-symbol alphabet (no ambiguous 0/O/1/I). Uniqueness is not guaranteed locally; the server's primary key/unique constraint is the backstop.
- Cancellation policy — free cancellation until **60 minutes** before `startTimeMs`; inside that window the **₹20** late fee applies. `cancel_reservation` applies the same policy server-side, so the client copy is explanatory, not authoritative.
- Expiry — an unclaimed `RESERVED` slot past its end becomes `EXPIRED`; helpers decide whether a row is still active.
- `MAX_HOLD_HOURS = 12` mirrors the server cap; the car and phone both refuse a longer window before calling.

Unit-tested in `BookingAndMeterTest`.

---

## `engine/billing/BillingEngine.java` (226 lines)

Computes an **estimate** only; the server recomputes and stores the real bill. Line items:

- energy = `verifiedKwhConsumed × pricePerKwh` (tariff default **₹18/kWh** when a station has no price);
- service fee (default **₹5**) and gateway fee (default **₹4**), both per session/booking as stored on the station;
- late-cancellation fee **₹20** when applicable;
- adjustment and `finalTotal`, rounded to paise.

It also exposes the billing lines for `ReceiptFragment` and the host analytics totals. Meter billing is allowed only for `LEVEL_1_VERIFIED_MANUAL` or `LEVEL_2_SIMULATED_SMART_METER`; `LEVEL_3_NO_VERIFIED_METER` is discovery-only (`ChargerStation.supportsPaidEnergyBilling()`), enforced again by `CarBridge.reserveNextFreeSlot` and the reservation screen.

Unit-tested in `BookingAndMeterTest` and `EngineUnitTest`.

---

## `engine/meter/MeterSimulator.java` (114 lines)

Demo meter for the pilot. Produces a plausible kWh figure for a session duration/power, and flags a reading above **150 kWh** as implausible. Readings carry `isSimulated=true` and the station's verification level; the UI labels them "Demo meter" (`session_demo_meter`, `session_simulate_delivers`). It is not a hardware integration: there is no OCPP, Modbus or charger API anywhere in the tree.

Unit-tested in `BookingAndMeterTest`.

---

## `engine/routing/RoutePlannerEngine.java` (613 lines)

The planner. Inputs: origin/destination, vehicle, candidate stations, corridor width, preference, exclusions. Algorithm:

1. **Corridor filter** — keeps stations within `corridorKm` of the straight route using `GeoUtils`; live/approved/compatible stations only.
2. **Greedy stop selection** — walks the route, picks the farthest safely reachable station that keeps the arrival reserve, adds it, repeats until the destination is reachable. Charging time uses station power capped by the vehicle's AC/DC limit and an **0.8** efficiency factor, with a 10-minute floor.
3. **Backups** — for each primary stop, adds nearby alternatives marked `isBackup=true`; they are never counted as the plan's main chain.
4. **Exclusions** — user-excluded station ids are skipped (and can be cleared to replan).
5. **Confidence** — HIGH/MEDIUM/LOW from station density, corridor coverage and reserve margin; written to `RoutePlan.confidence` and explained in `assumptions`.
6. **Timing** — `driveMinutes` from **45 km/h**, plus detour and charging minutes → `totalJourneyMinutes`. This is the number the phone shows; `TripTimeEngine`'s 60 km/h is not used here (Q1).
7. **Output** — a `RoutePlan` plus ordered `RouteStop`s (primary and backup), each with arrival/departure SoC, energy added, cost estimate and reason.

No network call: the caller supplies the route geometry/candidates. Unit-tested in `RoutePlannerRouteTimeTest` and `EngineUnitTest`.

---

## `engine/routing/TripTimeEngine.java` (28 lines)

A small legacy estimator that derives trip minutes at **60 km/h**. It is the only place with that speed; `GeoUtils` and the planner use 45. It is still referenced by tests (`TripTimeEngineTest`) but the planner does not use it for the journey total. This is a real inconsistency in displayed ETAs if any screen calls it directly (Q1).

---

## `engine/soc/SoCEstimatorEngine.java` (409 lines)

Battery planning and correction. Three public behaviours:

### `estimateSocAfterDistance(startSoc, distanceKm, vehicle)` and `estimateStartingSoc(vehicle, typicalDailyDistanceKm)`
Drain = `(distance / effectiveEfficiency) / effectiveCapacity × 100`. With no vehicle profile it falls back to 5 km per percentage point, and a neutral **60 %** starting estimate. `estimateStartingSoc` clamps to **20–95 %** and returns a `SocEstimate` with `fromProfile=true` and an explicit source string ("…not a reading from the car"). The UI must label it an estimate; the class cannot enforce that.

### `applyAuthoritativeSocOverride(...)`
The core correction path used by the phone (`ChargerDiscoveryFragment` battery update) and car (`CarBridge.applyBatteryUpdate`):

- reserve = explicit override, else `vehicle.minArrivalSocPercent`, else **15 %**;
- for each live, connector-compatible candidate: distance from the **current** position, detour, SoC used, arrival SoC;
- stations with arrival ≥ reserve are `safe`, others `unreachable`; stations not in the previously-reachable list become `newlyReachable`;
- the recommended stop is the nearest safe option; charging target respects `maxChargeSocPercent`, adds at least 10 points, and charging minutes use `min(station power, vehicle AC/DC) × 0.8` with a 10-minute floor;
- estimated usable range = `(actualSoc − reserve)/100 × capacity × efficiency`;
- journey time = remaining drive (45 km/h) + detour + charging;
- when nothing is safe, `noSafeCharger=true`, a warning says Amperly did **not** route beyond range, and the reservation advice explains the free-cancellation cut-off;
- always emits a `BatteryUpdate` audit row with previous estimate, actual value, position and timestamp.

Note: with no vehicle it defaults to **40 kWh** and **6.5 km/kWh**. `CarBridge` passes `plan.getTotalDistanceKm() * 0.6` as the remaining distance because the car has no GPS fix.

### `safeAlternatives(stations, soc, lat, lng, vehicle, maxResults)`
Sorted nearest-first list of stations reachable with the reserve intact; used for the car snapshot (max 5) and the "no safe charger" alternatives.

Unit-tested indirectly through `EngineUnitTest` and `AppStateStoreTest`; the correction maths is pure and deterministic.

---

## `engine/admin/EnforcementPolicyEngine.java` (145 lines)

Evidence-based host enforcement, exactly as implemented:

- `forUnverifiedAccusation()` → no action, no penalty, payout not frozen; tells the consumer what evidence is needed.
- `decide(provenIncidentsIncludingThis, evidenceSufficient, severeFraud)`:
  - insufficient evidence → action `NONE`, **payout frozen** while the host responds;
  - severe fraud → immediate **suspension + ban**, payout frozen, fine **0**;
  - 1st proven → **WARNING**, no fine;
  - 2nd → **FINE ₹500**;
  - 3rd → **SUSPENSION**, ₹500, payout frozen;
  - 4th+ → **BAN**, ₹500, suspension + ban + payout frozen.
- `suggestedSuspensionDays` → 1 / 7 / 30 days for incident 1 / 2 / 3+; `SUSPENSION_DAYS = {1,7,30}`; `DAY_MS`.
- `DEFAULT_FINE_INR = 500.0`.

This is a policy calculator only; `apply_host_enforcement` writes the record and pauses the station. Unit-tested in `EnforcementPolicyTest`.

---

## `engine/analytics/HostAnalyticsEngine.java` (172 lines)

`compute(stations, ports, sessions, reservations, invoices, disputes)` returns `HostAnalytics`:

- completed sessions = status `COMPLETED`, `DISPUTED` or `REFUNDED`;
- energy = Σ `max(0, verifiedKwhConsumed)`; minutes = Σ `max(0, end−start)`;
- repeat consumers = consumers with >1 completed session;
- revenue = Σ `invoice.finalTotal`; adjustments = Σ `invoice.adjustment`;
- cancellation rate = `(CANCELLED + EXPIRED) / all reservations × 100`;
- active reservations via `Reservation.isActive()`; open disputes via `Dispute.isOpen()`;
- utilization = session minutes / `ports × 12 h × 60 × 30 days`, capped at 100 %, explicitly labelled an **estimate** because there is no telemetry;
- average session kWh; port count; round2 on all doubles.

`describe()` formats a one-line summary for logs/cards. Unit-tested in `HostAnalyticsEngineTest`.

---

## `payment/PaymentManager.java` (164 lines)

The payment façade. It creates/updates `Payment` rows with an idempotency key, models authorization → capture → refund/release, and computes the late-cancellation fee. **No gateway SDK or network charge exists in the build**: `authorize_payment` is documented as not called, and the server marks an invoice `PAID` only if a payment row exists. The manager therefore represents the intended lifecycle and lets the UI show statuses without moving money. Unit-tested in `PaymentManagerTest` (idempotency, capture/refund transitions, fee).

---

## `communication/ChatManager.java` (159 lines)

Reservation-scoped chat: creates/loads a `CommunicationThread` for a reservation, exposes masked consumer/host numbers (never raw phone numbers), sends messages with sender/receiver ids, enforces the thread's `isChatEnabled`/`isBlocked` flags and expiry, and marks messages read/reported. Quick-question strings are UI constants in `fragment_host_chat.xml`/`strings.xml`. Unit-tested in `ChatManagerTest`.

---

## Engine boundaries

- Engines never read SharedPreferences, Room or the network; inputs are entities/primitives.
- The server is authoritative for slot ownership, billing, cancellation fees, approval and enforcement. Engines compute the same rules so the UI can explain them offline.
- Defaults that a reader should know: 45 km/h planner speed, 60 km/h legacy trip speed, 15 % reserve, 80 % default charge target, 0.8 charging efficiency, ₹18/kWh fallback tariff, ₹5 service, ₹4 gateway, ₹20 late fee, ₹500 enforcement fine, 12-hour maximum hold, 60-minute free-cancellation window.
