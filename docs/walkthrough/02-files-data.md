# 02 — Files: `data/` (56 files)

This is the persistence and network layer. Room is a **cache**, Supabase/Postgres is the **authority**; the repository writes Room first and then PostgREST, and money transitions go through Postgres functions. All 23 entities, all 23 DAOs, `AmperlyDatabase`, the 8 `remote` files and `AmperlyRepository` were read in full. Declaration lines: `09-symbol-index.md`.

---

## 1. `data/local/AmperlyDatabase.java` (122 lines)

`@Database(version = 6, entities = 23, exportSchema = false)`. It declares one abstract DAO per entity and builds the database with `Room.databaseBuilder(...).addMigrations(MIGRATION_5_6).fallbackToDestructiveMigration()`.

Observed facts:
- **Version 6**, while `README.md` still says v5 (finding Q3).
- `MIGRATION_5_6` is registered; its statements were not read line-by-line (see `08-completeness-check.md`).
- Destructive fallback means a future unhandled migration wipes the cache; the server can refill it, but unsynced local writes would be lost. Acceptable for a cache, worth knowing for support.
- No `@TypeConverters`; all fields are primitives/String, so Room maps columns 1:1. No entity uses `@ColumnInfo`, which is why the quoted camelCase Supabase columns deserialize directly.

---

## 2. Entities — 23 files

Every entity is a plain Java class with a public constructor, getters/setters and convenience predicates; there are no annotations beyond `@Entity`/`@PrimaryKey`. Column names equal field names.

| Entity (lines) | Fields (semantic) | Predicates / notes |
|---|---|---|
| `User` (86) | id, authUserId (server-only, not in Room), name, email, phone, role, organizationName, verificationStatus, isBlocked, serverUpdatedAt | `isPlatformAdmin()` used by `MainActivity.onSignedIn` |
| `Vehicle` (148) | id, userId, make, model, variant, purchaseYear, batteryCapacityKwh, connectorType, maxAcKw, maxDcKw, typicalEfficiencyKmPerKwh, batteryHealthPercent, efficiencyCorrectionPercent, minArrivalSocPercent, maxChargeSocPercent, licensePlate, isActive | `effectiveCapacityKwh()`, `effectiveEfficiencyKmPerKwh()` apply health/correction; used by planner and SoC |
| `ChargerStation` (189) | id, hostId/hostName, name, address, lat/lng, locationType, operatingHours, pricePerKwh, serviceFee, gatewayFee, verificationLevel, isVerified, isPaused, approvalStatus, reviewNote, connectorTypes, maxPowerKw, isDcCapable, portCount, accessRules, rating, reliabilityScore, incidentCount, lastUpdatedMs | `isLiveOnMarketplace()`, `supportsPaidEnergyBilling()`, `isDcCapable()`; the last two gate booking and meter billing |
| `ChargerPort` (52) | id, stationId, portNumber, connectorType, powerKw, isDc, status | port label/status used by reservation |
| `AvailabilitySchedule` (67) | id, stationId, portId, dayOfWeek, openMinutes, closeMinutes, isBlocked, blockReason, updatedAtMs | weekly opening window; `AvailabilityEngine` input |
| `Reservation` (124) | id, consumerId, stationId/Name, portId/Label, bookingCode, start/end ms, status, pricePerKwh, serviceFee, gatewayFee, cancellationFee, isPaid, paymentId, checkedInAtMs, cancelledAtMs, createdAtMs | `isActive()`, cancellation predicates |
| `ChargingSession` (125) | id, reservationId, consumerId, hostId, stationId/Name, portId, start/end ms, starting/ending meter kWh, verifiedKwhConsumed, energyCharge, serviceFee, gatewayFee, totalPaid, status, meterReadingId, invoiceId, isMeterSimulated, verificationLevel | live/complete predicates |
| `MeterReading` (62) | id, sessionId, stationId, start/end meter kWh, photoEvidenceUri, verificationLevel, timestampMs, isSimulated | evidence for a session |
| `Invoice` (93) | id, sessionId, consumerId, hostId, stationName, verifiedKwh, energyCharge, serviceFee, gatewayFee, adjustment, adjustmentNote, finalTotal, paymentId, status, issuedAtMs | `finalTotal` is server-authoritative |
| `Payment` (107) | id, reservationId, sessionId, consumerId, hostId, idempotencyKey, gateway, gatewayReference, authorized/captured/refunded amounts, lateCancellationFee, status, failureReason, createdAt/updatedAt | no gateway is connected; rows exist but no money moves |
| `RoutePlan` (158) | id, consumerId, vehicleId, origin/destination + lat/lng, corridorKm, preference, totalDistanceKm, drive/detour/charging/totalJourney minutes, plannedStartSoc, arrivalSocTarget, isSocAuthoritative, assumptions, confidence, status, routeProvider, googlePlaceId, createdAt/updatedAt | `confidence` HIGH/MEDIUM/LOW; `status` DRAFT/ACTIVE/COMPLETED/CANCELLED |
| `RouteStop` (104) | id, planId, sequence, stationId/Name, isBackup, isReachable, distanceAlongRouteKm, detourKm/Minutes, arrival/departure Soc, energyAddedKwh, chargingMinutes, estimatedCost, recommendationReason, reservationId | `isBackup()` separates primary stops from fallbacks |
| `TripEstimate` (76) | id, planId, vehicleId, segmentDistanceKm, estimated/actual drain kWh, estimated/actual arrival Soc, confidence, notes, createdAtMs | audit of a plan's prediction |
| `BatteryUpdate` (57) | id, vehicleId, tripPlanId, estimatedSoc, actualDashboardSoc, lat/lng, timestampMs | written by `SoCEstimatorEngine.applyAuthoritativeSocOverride` and `CarBridge.applyBatteryUpdate` |
| `CommunicationThread` (93) | id, reservationId, consumer/host ids and names, masked numbers, isReported, isBlocked, isChatEnabled, createdAt, expiresAt | chat is reservation-scoped and time-limited |
| `ChatMessage` (67) | id, threadId, reservationId, senderId, receiverId, messageText, createdAt, isRead, isReported, expiresAt | |
| `SafetyEvent` (57) | id, consumerId, stationId, emergencyType, liveLocationSharing flag, trustedContactPhone, expiresAt, createdAt | SOS record |
| `TrustedContact` (35) | id, userId, name, phone | SOS contacts |
| `Report` (67) | id, reporterId/Name, targetStationId, targetHostId, sessionId, reportType, description, status, createdAt | status OPEN/REVIEWED/RESOLVED |
| `Dispute` (113) | id, sessionId, consumerId/Name, hostId, stationId/Name, reason, consumerNotes, hostNotes, evidence, status, enforcementAction, refundAmount, resolutionNote, isPayoutFrozen, createdAt, resolvedAt | `isOpen()` used by analytics/admin |
| `HostEnforcementAction` (67) | id, hostId, stationId, actionType, reason, fineAmount, createdAt, expiresAtMs | suspension end; 0 = permanent |
| `Notification` (46) | id, userId, title, message, isRead, createdAt | inbox |
| `AndroidAutoSession` (67) | id, userId, vehicleId, planId, lastTemplateShown, lastSocUpdatePercent, connectedAt, lastSocUpdateAt, disconnectedAt | written by `AmperlyCarSession` |

Server-only columns not present on the Room entities: `users.authUserId` and every `serverUpdatedAt`. The repository includes `authUserId` explicitly when inserting a user (the entity alone would be rejected by the insert policy).

---

## 3. DAOs — 23 files

Each DAO is an interface annotated `@Dao`. The common pattern is: `LiveData<List<X>> observe...` / `List<X> ...Sync`, `@Insert(onConflict = REPLACE)`, `@Update`, `@Delete`, plus entity-specific queries. No DAO contains business logic.

| DAO (lines) | Entity | Notable queries / role |
|---|---|---|
| `UserDao` (42) | User | by id, by auth id, observe current, upsert |
| `VehicleDao` (66) | Vehicle | by user, active vehicle (`isActive = 1`), clear-active then set-active |
| `ChargerStationDao` (58) | ChargerStation | approved/live list, by host, pending queue, observe one |
| `ChargerPortDao` (47) | ChargerPort | by station, by id |
| `AvailabilityScheduleDao` (49) | AvailabilitySchedule | by port, by station, day window |
| `ReservationDao` (62) | Reservation | by consumer, by station/host, active, by booking code |
| `ChargingSessionDao` (48) | ChargingSession | by consumer/host, active, by reservation |
| `MeterReadingDao` (39) | MeterReading | by session |
| `InvoiceDao` (45) | Invoice | by consumer/host, by session |
| `PaymentDao` (42) | Payment | by reservation/session |
| `RoutePlanDao` (39) | RoutePlan | active plan, by consumer, by id |
| `RouteStopDao` (42) | RouteStop | by plan ordered by sequence |
| `TripEstimateDao` (29) | TripEstimate | by plan |
| `BatteryUpdateDao` (32) | BatteryUpdate | by vehicle/plan |
| `CommunicationThreadDao` (59) | CommunicationThread | by reservation, by consumer/host, unread |
| `ChatMessageDao` (52) | ChatMessage | by thread ordered by time, unread count |
| `SafetyEventDao` (37) | SafetyEvent | latest by consumer |
| `TrustedContactDao` (30) | TrustedContact | by user |
| `ReportDao` (39) | Report | queue/all, by status |
| `DisputeDao` (42) | Dispute | open/all, by host/consumer |
| `HostEnforcementActionDao` (43) | HostEnforcementAction | by host, active suspension |
| `NotificationDao` (36) | Notification | by user, unread |
| `AndroidAutoSessionDao` (32) | AndroidAutoSession | by user, latest |

`LiveData` is used by several DAOs (e.g. station/reservation lists), but no fragment observes it directly; screens read synchronously on the repository's background executor and render in the main-thread callback. This makes the `lifecycle`/`LiveData` dependencies mostly unused at the UI layer (finding Q10).

---

## 4. `data/remote` — 8 files

### `SupabaseConfig.java` (49 lines)
Exposes `BuildConfig.SUPABASE_URL` and `BuildConfig.SUPABASE_PUBLISHABLE_KEY`; `isConfigured()` is false when either is blank; `looksLikeSecretKey()` rejects `sb_secret_`/`service_role`. `MainActivity.startBackend` refuses to run when unconfigured or when the key is a secret, showing `auth_secret_key` / sign-in instead. Gradle also rejects secret keys at build time.

### `SupabaseApi.java` (98 lines)
String constants for the PostgREST endpoints and RPC names used by the client (`/rest/v1/<table>`, `/auth/v1/...`, `rpc/create_reservation`, `rpc/finalize_charging_session`, `rpc/cancel_reservation`, `rpc/decide_station_approval`, `rpc/resolve_dispute_refund`, `rpc/freeze_dispute_payout`, `rpc/apply_host_enforcement`). Keeping names here prevents drift between repository and server.

### `SupabaseClient.java` (148 lines)
Shared `OkHttpClient` and request builder: base URL, `apikey`, `Authorization: Bearer <access token>`, JSON headers, timeouts. It exposes `get/post/patch/delete` and refreshes the token once on 401 via `SupabaseAuth`. One client for the process; no retry storm.

### `SupabaseAuth.java` (567 lines)
GoTrue client and secure session store:
- `signUp`, `signInWithPassword`, `signOut`, `refresh`, `restoreSession`, `hasStoredSession`, `isSignedIn`.
- Tokens live in `EncryptedSharedPreferences` under `amperly_supabase_session_secure`; the legacy plain file `amperly_supabase_session` is migrated then cleared.
- Access token refresh is proactive before expiry and reactive on 401; failure is **fail-closed** (session cleared, sign-in shown) rather than silently continuing with an expired token.
- The custom-scheme `amperly://auth-callback` is treated only as "the user came back"; it is never accepted as proof of email confirmation (`MainActivity.handleDeepLink`).
- `SupabaseAuth.isSignedIn()` gates the sign-out menu item.

### `SupabaseRest.java` (391 lines)
Typed PostgREST wrapper: builds `eq`/`select`/`order` query strings, serialises entities to JSON (snake/camel preserved), maps non-2xx responses to `SupabaseException` with PostgREST `code`/`message`/`details`/`hint`, and exposes `select`, `insert`, `upsert` (`Prefer: resolution=merge-duplicates`), `update`, `delete`, `rpc`. It is the only class that knows HTTP verbs. Unit-tested in `SupabaseRestTest`.

### `SyncEngine.java` (328 lines)
Incremental pull/push:
- **Pull** reads rows whose `serverUpdatedAt` is newer than a stored cursor, page size **500**, max **20** pages; writes them into Room with `REPLACE`.
- **Id reconciliation**: because hard deletes leave no tombstone, it also lists ids (max **40** pages) and deletes local rows missing remotely, but only when the id pages did not hit the guard — otherwise it skips deletion to avoid wiping the cache on a partial read.
- **Push** uploads local rows for the tables the user can write; dirty deletes go through raw SQL markers.
- `syncNow(context, db)` returns a `Result.summary()`; `MainActivity.syncAfterSignIn` logs it and rebuilds the visible tab.
- No offline write queue: a refused write is reported, not retried.

### `SyncReconciler.java` (47 lines)
Pure diff helper: given local and remote id sets, returns ids to delete and ids to keep. Extracted so the dangerous part is unit-tested (`SyncReconcilerTest`).

### `SyncTables.java` (147 lines)
Declarative list of synced tables: Room DAO accessor, PostgREST table name, primary key, user-scoping column, and whether the client may push. This is the map `SyncEngine` iterates; adding a table requires an entry here.

---

## 5. `data/repository/AmperlyRepository.java` (1,935 lines)

The single data hub. `getInstance(context)` returns a process singleton; every public method is either a synchronous `...Sync` call (must run on a background thread) or an async method taking a `background(...)` callback. `background(work, callback)` uses a single-thread executor and posts the callback to the main thread.

Responsibilities, by area:

1. **Session/user** — `resolveOrCreateAppUser(authUserId, email, name)`, `getUserSync`, `accountRestrictionMessage(user)` (ban/suspension text), `didProfileWriteFail()` (profile insert failed → app looks empty under RLS), `clearLocalData()`.
2. **Vehicles** — active vehicle, list, save (clears other `isActive` flags in one transaction), delete.
3. **Stations/ports/schedules** — approved station list, station by id, ports, slots (`getSlots` delegates to `AvailabilityEngine`), host stations, create/update/pause/delete, admin approval queue.
4. **Route plans/stops** — save a plan and its stops, active plan, stops by plan, mark complete/cancel, battery updates.
5. **Reservations** — `createReservationConfirmed(...)` calls the `create_reservation` RPC (never inserts directly), returns `BookingResult {success, message, reservation}` with server refusals (`reserve_slot_taken`, `reserve_slot_in_past`, `reserve_slot_too_long`, `reserve_station_unavailable`, `reserve_server_required`), check-in, cancel (RPC), booking code lookup.
6. **Sessions/billing** — start session, save meter reading, `finalizeChargingSession` via RPC, invoice/receipt, dispute creation. The client may compute an estimate (`BillingEngine`) but cannot store billing columns; the server recomputes.
7. **Payments** — payment rows and status; `PaymentManager` is the UI-facing wrapper. No gateway call is made by this build.
8. **Chat/safety/notifications** — threads, messages, trusted contacts, SOS events, notification inbox.
9. **Android Auto** — `saveAutoSession`.
10. **Sync** — `syncNow` delegates to `SyncEngine`; the repository owns the Room instance (`database()`).

Write discipline observed throughout: **Room write first**, then PostgREST; a remote failure is logged and surfaced, and the local row remains (cache semantics). For money and bookings the order is inverted: the RPC must succeed before the local row is treated as confirmed, because the server owns the slot and the amount.

---

## 6. Data-layer invariants

- Primary keys are client-generated UUID strings (`UUID.randomUUID().toString()`), except `User.id` which is the app user id resolved from the auth account.
- There are no Room foreign keys; relationships are logical ids. Deleting a parent does not cascade locally; Supabase handles cascade on account deletion.
- Every server table has `serverUpdatedAt` stamped by a trigger; the app never writes it.
- Supabase RLS is the only authorization boundary. The repository's role checks are UX, not security.
- 23 tables on both sides; `users.authUserId` and `serverUpdatedAt` are the only server-only columns.
