# 04 — Data layer and database contract

Sources: all 23 Room entities, all 23 DAOs, `AmperlyDatabase`, the 8 `remote` classes, `AmperlyRepository` (1,935 lines), `supabase/schema.sql` (2,447 lines; tables 61–486, policies 975–1373, functions/triggers indexed in `09-symbol-index.md` and below), `supabase/security_hardening.sql` (173), `supabase/README.md`.

---

## 1. The shape of the data layer

```
Fragment / car screen
   ↓ repository methods (background executor)
AmperlyRepository ──► Room (cache, 23 DAOs)  ──► UI callback
   ↓
SupabaseRest (PostgREST) ──► Supabase Postgres (authority, RLS)
   ↑
SupabaseAuth (GoTrue token, refresh, fail-closed)
```

- Room is **not** the source of truth. Every table is also a Postgres table with the same quoted camelCase columns.
- The app **writes Room first** for ordinary rows, then PostgREST. If the server refuses, the local copy remains but is not re-sent (no queue); the account screen reports sync failures.
- Booking, cancellation, settlement, approval, disputes and enforcement are **server-first** RPCs; local state changes only after success.
- No DTO/mapping layer: PostgREST JSON keys equal Java field names equal Room column names.
- No Room foreign keys and no `@TypeConverters`; all fields are primitives/String.

---

## 2. The 23 tables

All tables have `id text primary key` plus `"serverUpdatedAt" timestamptz not null default now()`, stamped by a trigger on update. Table definitions start at line 61 of `schema.sql`.

| # | Table | Key columns | Logical parent / relationship |
|---|---|---|---|
| 1 | `users` | id, authUserId (uuid, unique, FK auth.users on delete cascade), name, email, phone, role, organizationName, verificationStatus, isBlocked | root profile; `current_app_user_id()` resolves JWT → users.id |
| 2 | `vehicles` | id, userId, make/model/variant/year, capacity, connector, max AC/DC, efficiency, health, correction, min/max SoC, plate, isActive | user; one active profile per account (app clears others) |
| 3 | `charger_stations` | id, hostId/hostName, name/address/lat/lng, locationType, hours, price/service/gateway, verificationLevel, isVerified, isPaused, approvalStatus, reviewNote, connectorTypes, maxPowerKw, isDcCapable, portCount, accessRules, rating, reliability, incidents, lastUpdatedMs | host; ports, schedules, reservations, sessions |
| 4 | `charger_ports` | id, stationId, portNumber, connectorType, powerKw, isDc, status | station |
| 5 | `availability_schedules` | id, stationId, portId, dayOfWeek 1–7, open/close minutes, isBlocked, blockReason, updatedAtMs | port/station |
| 6 | `reservations` | id, consumerId, stationId/Name, portId/Label, bookingCode, start/end ms, status, price/service/gateway, cancellationFee, isPaid, paymentId, checkedInAt/cancelledAt/createdAt | consumer + station + port; **insert only via `create_reservation`** |
| 7 | `charging_sessions` | id, reservationId, consumerId, hostId, station/port, start/end, starting/ending meter kWh, verifiedKwh, energy/service/gateway, totalPaid, status, meterReadingId, invoiceId, isMeterSimulated, verificationLevel | reservation; billing columns pinned by trigger |
| 8 | `meter_readings` | id, sessionId, stationId, start/end kWh, photoEvidenceUri, verificationLevel, timestampMs, isSimulated | session |
| 9 | `invoices` | id, sessionId, consumerId, hostId, stationName, verifiedKwh, energy/service/gateway, adjustment, adjustmentNote, finalTotal, paymentId, status, issuedAtMs | session; **server writes only** |
| 10 | `payments` | id, reservationId, sessionId, consumerId, hostId, idempotencyKey (unique), gateway, gatewayReference, authorized/captured/refunded, lateCancellationFee, status, failureReason, timestamps | reservation/session; money fields pinned |
| 11 | `route_plans` | id, consumerId, vehicleId, origin/destination + lat/lng, corridorKm, preference, total/drive/detour/charging/journey minutes, plannedStartSoc, arrivalSocTarget, isSocAuthoritative, assumptions, confidence, status, routeProvider, googlePlaceId, timestamps | user + vehicle; stops/estimates |
| 12 | `route_stops` | id, planId, sequence, stationId/Name, isBackup, isReachable, distanceAlongRouteKm, detour km/min, arrival/departure SoC, energyAdded, chargingMinutes, estimatedCost, recommendationReason, reservationId | plan |
| 13 | `trip_estimates` | id, planId, vehicleId, segment km, estimated/actual drain, estimated/actual arrival SoC, confidence, notes, createdAt | plan |
| 14 | `battery_updates` | id, vehicleId, tripPlanId, estimatedSoc, actualDashboardSoc, lat/lng, timestampMs | vehicle/plan; written by SoC correction |
| 15 | `communication_threads` | id, reservationId, consumer/host id+name, masked numbers, isReported, isBlocked, isChatEnabled, createdAt, expiresAt | reservation |
| 16 | `chat_messages` | id, threadId, reservationId, senderId, receiverId, messageText, createdAt, isRead, isReported, expiresAt | thread |
| 17 | `safety_events` | id, consumerId, stationId, emergencyType, liveLocationSharing, trustedContactPhone, expiresAt, createdAt | user/station |
| 18 | `trusted_contacts` | id, userId, name, phone | user |
| 19 | `reports` | id, reporterId/Name, targetStationId, targetHostId, sessionId, reportType, description, status, createdAt | reporter; moderation queue |
| 20 | `disputes` | id, sessionId, consumerId/Name, hostId, stationId/Name, reason, consumerNotes, hostNotes, evidence, status, enforcementAction, refundAmount, resolutionNote, isPayoutFrozen, createdAt, resolvedAt | session; admin resolution |
| 21 | `host_enforcements` | id, hostId, stationId, actionType, reason, fineAmount, createdAt, expiresAtMs (0 = permanent) | host/station; policy outcome |
| 22 | `notifications` | id, userId, title, message, isRead, createdAt | user inbox |
| 23 | `android_auto_sessions` | id, userId, vehicleId, planId, lastTemplateShown, lastSocUpdatePercent, connectedAt, lastSocUpdateAt, disconnectedAt | user/vehicle/plan; car audit |

There are **no physical foreign keys** except `users.authUserId → auth.users(id) on delete cascade`. All other links are ids enforced by RLS/RPC logic, not by constraints. That is a deliberate MVP trade-off but means orphan rows are possible if a delete path is added outside the auth trigger.

---

## 3. Identity and RLS

### Identity
- `public.current_app_user_id()` (line 38) is `stable security definer set search_path = public`; it maps the JWT's `auth.uid()` to `users.id` via `authUserId`. SECURITY DEFINER avoids infinite policy recursion.
- `public.is_admin()` (line 50) resolves the caller's role.
- A trigger on `auth.users` (`on_auth_user_created`, around line 669) creates the `public.users` row; a backfill at the end repairs accounts created before it.
- Creating the Auth account is the only required step; the app also inserts its own profile as a fallback, including the server-only `authUserId`.

### RLS
RLS is enabled on all 23 tables (policies at lines 975–1373; 50+ policies). Role matrix from `supabase/README.md`:

| Capability | Anon | Consumer | Host | Admin |
|---|---|---|---|---|
| Browse approved/live stations, ports, schedules | ✅ | ✅ | ✅ | ✅ |
| See pending/paused stations | ❌ | ❌ | own | ✅ |
| Own vehicle/plans/battery updates | ❌ | ✅ | ✅ | ✅ |
| Own reservations/sessions/invoices | ❌ | ✅ | — | ✅ |
| Reservations/sessions for own stations | ❌ | — | ✅ | ✅ |
| Write meter reading | ❌ | own session | own station | ✅ |
| Capture/refund/cancel/settle | ❌ | via RPC | via RPC | ✅ |
| Issue invoice/refund/resolve dispute | ❌ | ❌ | ❌ | ✅ |
| Chat | ❌ | participant | participant | ✅ |
| Change role/block state | ❌ | ❌ | ❌ | ✅ |

Two hard rules: a consumer cannot decide what they are charged (invoices have no client write policy; billing columns and payment money fields are pinned by triggers; the server recomputes), and a user cannot promote themselves (`prevent_privilege_escalation` trigger rejects role/block/verification changes by non-admins).

### `security_hardening.sql` (173 lines)
Idempotently replaces trigger functions that close listing self-approval, forged reputation, dispute self-resolution and self-marked payments. It must be run on projects created before it existed; `schema.sql` alone is not enough for those.

---

## 4. Functions and triggers (server)

Function names and line numbers in `schema.sql` (from the object index):

`current_app_user_id` 38, `is_admin` 50, `set_server_updated_at` 514, `prevent_privilege_escalation` 527, `prevent_payment_tampering` 540, `prevent_session_billing_tampering` 564, `prevent_station_self_approval` 606, `prevent_reputation_forgery` 656, `handle_new_auth_user` 726, `notify_station_approval` 842, `create_reservation` 1400, `cancel_reservation` 1409, `authorize_payment` 1492, `finalize_charging_session` 1597, `decide_station_approval` 1837, `resolve_dispute_refund` 1928, `freeze_dispute_payout` 1987, `apply_host_enforcement` 2059, plus helper/trigger functions at 2079, 2138, 2172, 2206, 2246, 2289, 2333.

Triggers at approximately 669, 855, 947, 2162, 2196, 2237, 2279, 2323, 2358.

Contract highlights:
- `create_reservation`: per-port advisory lock, validates the window against live reservations, reads the station's real tariff, inserts; caps a hold at **12 hours**; the only INSERT path.
- `finalize_charging_session`: caller must be that reservation's consumer or host; recomputes from meter readings; writes session + invoice, closes reservation, frees port, invoice `PAID` only if a payment row exists (else `ISSUED`).
- `cancel_reservation`: applies the 60-minute/₹20 policy server-side and releases any hold.
- `decide_station_approval`: admin only; approves/rejects and notifies the host.
- `resolve_dispute_refund` / `freeze_dispute_payout`: admin only; refund invoice energy charge/payment, resolve dispute, freeze host payout.
- `apply_host_enforcement`: records the action and pauses the station when policy requires.
- `authorize_payment`: exists but is **not called by this build** (no gateway).

A refused write is reported, not queued. After settlement the app must pull so server amounts replace local estimates.

---

## 5. Money model

Local estimate (`BillingEngine`): energy = verified kWh × tariff (fallback **₹18/kWh**), + service **₹5** + gateway **₹4**, + adjustment; late cancellation **₹20**. Enforcement fine **₹500**.

Server authority: `finalize_charging_session` recomputes energy from meter readings and writes `invoices.finalTotal`; `payments` money fields can only be changed by settlement functions; `invoices` has no client INSERT/UPDATE policy. No gateway is connected, so no money is actually captured in this build; the lifecycle (AUTHORIZED → CAPTURED/REFUNDED/RELEASED) is modelled but `authorize_payment` is unused.

---

## 6. Sync semantics and failure modes

- Cursor: raw `serverUpdatedAt` of the newest pulled row; page **500**, max **20** pages.
- Deletes: no tombstones, so ids are listed (max **40** pages) and `SyncReconciler` deletes local rows missing remotely. If the id scan hits its guard, deletion is skipped — safer to keep stale rows than to wipe a cache on a partial read.
- Push: writable tables only (`SyncTables`), per-row upsert/patch; dirty deletes via raw SQL markers.
- On a different account sign-in, `MainActivity` calls `clearLocalData()` first; same account keeps cache for offline use.
- Failure surface: account screen sync status / toast. There is no background sync, no WorkManager, no retry queue.
- Pull is not transactional across tables; a screen rebuilt mid-pull can briefly show a partial graph. The post-sync rebuild mitigates the common case.

---

## 7. Deletion and retention

- Deleting the **Auth** user cascades the profile and all owned rows through the `auth.users` trigger (vehicles, plans, stops, battery updates, reservations, sessions, meter readings, invoices, payments, disputes, chats, safety events, contacts, notifications, Auto sessions; host stations with ports/hours).
- Deleting `public.users` alone only removes the profile — the app data remains; the README explicitly warns about this.
- Device cache is not reachable by the server: wiping app data is a manual step when handing on a phone.
- Chat/safety rows carry `expiresAtMs`; enforcement suspensions carry `expiresAtMs` (0 = permanent). Expiry is interpreted by the app/policy, not by a scheduled database job (no pg_cron observed).
