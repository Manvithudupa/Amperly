# 05 — End-to-end flows

Each flow lists the user action, the code path, the data written, and the failure surfaces. Screens are in `02-files-ui.md`; engine rules in `02-files-engines.md`.

---

## 1. First launch and sign-in

1. `MainActivity.onCreate` inflates `activity_main`, applies insets, restores tab tags, registers back handling, then `startBackend()`.
2. If `SupabaseConfig` is blank or `looksLikeSecretKey()`, sign-in is shown with `auth_secret_key` / `auth_offline_note`; there is no demo/seed path.
3. `SupabaseAuth.hasStoredSession` false → `showSignIn()`: toolbar and bottom nav hidden, `SignInFragment` in the container.
4. User enters name/email/password. `ValidationUtils` checks email shape and ≥6-character password.
5. Sign-in → `SupabaseAuth.signInWithPassword`; create account → `signUp`.
   - invalid credentials → `error_auth_invalid_credentials`;
   - unconfirmed email → `error_auth_email_unconfirmed` / `auth_confirm_email`;
   - already registered → `error_auth_already_registered`;
   - network → `auth_unexpected`.
6. Success → `SupabaseAuth` stores tokens in EncryptedSharedPreferences → `MainActivity.onSignedIn(user)`.
7. `onSignedIn`: `AuthManager.setCurrentUser`; active vehicle + `SocStore.load` → `AppStateStore.applyStoredSoc`; nav/chrome on; role = `user.isPlatformAdmin() ? ADMIN : CONSUMER`; toast; profile-write warning; `syncAfterSignIn`.
8. `syncAfterSignIn`: if the account id differs from `amperly_session.last_user_id`, `clearLocalData()`; insert the user row (with `authUserId`); `SyncEngine.syncNow`; rebuild the visible tab.
9. Restored session path: `restoreSession` → `resolveOrCreateAppUser` → `accountRestrictionMessage`; a banned/suspended account is signed out and shown the reason; otherwise `onSignedIn`.

**Writes:** encrypted token file; `users` row; Room pull. **Fails closed** at every auth step.

---

## 2. Discovery and battery correction

1. Consumer lands on Discover (`ChargerDiscoveryFragment`), or Trips if `TripSessionStore.hasActive`.
2. Fragment asks `LocationProvider` for a fix (permission-checked), loads approved stations, applies `StationVisibility` (APPROVED, not paused, live), computes distance with `GeoUtils.distanceKm`, renders `MapPanel` + list.
3. Battery hero shows stored/confirmed SoC (`AppStateStore`), labelled actual vs estimated; vehicle switcher opens `VehicleSwitcherDialog`.
4. “Update battery” opens `dialog_input_number`; the entered dashboard value is authoritative.
5. `SoCEstimatorEngine.applyAuthoritativeSocOverride`: recomputes safe/unreachable/newly reachable stations from the current position, remaining distance, reserve (vehicle min or 15 %), charging time and journey time.
6. Saves a `BatteryUpdate` audit row; updates `AppStateStore` (correction, explanation, no-safe-charger message, safe set); `SocStore` persists the value for 12 h per account+vehicle.
7. If nothing is reachable, the UI states Amperly did not route beyond range and offers alternatives/cancellation advice.
8. Tapping a station → `ChargerDetailsFragment`.

**No server write** for the battery value except the audit row through the repository; the drive itself continues offline.

---

## 3. Route planning

1. `RoutePlannerFragment`: origin from GPS or map pick; destination via `PlacesAutocomplete` (300 ms, ≥3 chars, ≤5) or `PlaceSearchDialog`.
2. Destination resolves through `GeoapifyGeocoder` (India only); failures show `error_place_search` / `error_place_not_found` / `error_address_lookup`.
3. User picks vehicle, preference (FASTEST/CHEAPEST/RELIABLE/SHORTEST_DETOUR), corridor, reserve; can exclude stations.
4. `GeoapifyRoutingClient` fetches the route (throttle 4/s, cache 20/10 min); `RoutePlannerEngine` filters the corridor, greedily selects stops, adds backups, computes confidence and 45 km/h timings.
5. Result rendered as stop list (`item_route_stop`), primary/backup badges, assumptions, arrival/departure SoC, cost.
6. Save writes `RoutePlan` + `RouteStop`s to Room and Supabase; the plan becomes ACTIVE; `AppStateStore.setActivePlan`.
7. “Start navigation” opens `InAppNavigationFragment`; `TripSessionStore` marks the trip active so the Trips tab restores it.
8. Failure: no route / no safe charger → planner explains and does not fabricate stops; provider errors map through `GeoapifyErrors`.

---

## 4. Reservation

1. From station details or Bookings tab (`ReservationFragment`), choose station (if not already), vehicle, port, slot.
2. Slots come from `AvailabilityEngine` (schedule minus reservations/port status); the UI shows the cancellation policy (free until 60 min before, then ₹20).
3. Confirm → `repo.createReservationConfirmed` → `POST rpc/create_reservation`:
   - advisory lock per port; window re-checked; real tariff read; insert; max 12 h.
4. Success → `BookingResult.reservation`; `AppStateStore.setActiveReservation` + booking code; `BookingQrFragment` shows the QR/code.
5. Refusals map to `reserve_slot_taken`, `reserve_slot_in_past`, `reserve_slot_too_long`, `reserve_station_unavailable`, `reserve_server_required`, `reserve_server_failed`; **nothing is reserved locally on failure**.
6. Consumer can cancel (RPC applies the fee), check in, open chat, or start the session.

---

## 5. Check-in, charging, billing

1. `ActiveSessionFragment`: check in (status CHECKED_IN), then start (CHARGING). Start meter reading is required.
2. Meter input via `MeterEvidenceDialog` (manual, end ≥ start) or `MeterSimulator` (demo, >150 kWh flagged implausible).
3. Live kWh/time/cost are derived locally; billing is an estimate.
4. “Stop and bill” → `finalize_charging_session` RPC. Server recomputes from meter readings, writes session + invoice, closes reservation, frees port, marks invoice PAID only if a payment row exists (else ISSUED).
5. Offline/refused → `session_server_required` / `session_server_failed`; **no receipt is issued**, local state stays open for retry.
6. Success → `ReceiptFragment` reads server amounts (energy, service, gateway, adjustment, total); consumer can dispute.
7. No gateway is connected, so no money is captured in this build.

---

## 6. Host onboarding and admin approval

1. Signed-in account switches to Host (`AccountFragment` role chips → `MainActivity.switchRole(HOST)`; `AuthManager.setRole` refuses if not entitled).
2. Host Dashboard shows analytics (`HostAnalyticsEngine`); Stations tab lists own stations.
3. “Add station” → `RegisterStationFragment`: name, address (GPS or geocoded), pin, tariff/service/gateway, connectors, power, ports, verification level, access rules, hours.
4. Save → station `PENDING` (`approvalStatus`), host cannot self-approve (server trigger `prevent_station_self_approval`).
5. Admin signs in → `AdminDashboardFragment` queue; approve/reject → `decide_station_approval` RPC; host notified (`notify_station_approval` / notifications).
6. Approved + not paused + live → station appears in consumer discovery. Paused/unapproved is invisible to consumers.
7. Host can pause/resume/edit/delete; deleting is a muted destructive action and removes the listing from discovery.

---

## 7. Dispute and enforcement

1. Consumer opens a completed session → `ReportDialog`/dispute → `Dispute` row (reason, notes, evidence), status open.
2. Admin Reports section (`DisputeAdapter`, `item_dispute`) reviews consumer/host notes and evidence.
3. Admin can refund (`resolve_dispute_refund`), freeze payout (`freeze_dispute_payout`), or apply enforcement (`apply_host_enforcement`).
4. Enforcement policy (`EnforcementPolicyEngine`):
   - unverified → no action, no penalty;
   - insufficient evidence → no action, payout frozen;
   - 1st proven → warning; 2nd → ₹500 fine; 3rd → suspension; 4th+ or severe fraud → ban (+ immediate suspension, payout freeze).
5. `apply_host_enforcement` records `HostEnforcementAction`, pauses the station when required, and notifies the host; `expiresAtMs` 0 means permanent.
6. Consumer reports are a separate queue (`Report` OPEN/REVIEWED/RESOLVED) and do not themselves trigger a penalty.

---

## 8. Chat and SOS

**Chat:** reservation-scoped `CommunicationThread` with masked numbers, `isChatEnabled`/`isBlocked`, expiry. Messages are `ChatMessage` rows; participants (and admin) can read per RLS; report/block flags surface to admin. No raw phone number is exposed.

**SOS:** `SafetySOSFragment` explains the action, creates a `SafetyEvent` with `isLiveLocationSharingActive` and expiry, and lists `TrustedContact`s (call/delete). The code does **not** call emergency services; it records and shares with trusted contacts. No background location service exists.

---

## 9. Android Auto

1. Phone projects; `AmperlyCarAppService` creates `AmperlyCarSession`.
2. Session records connect (`AndroidAutoSession`), sets `AppStateStore.carConnected=true`, opens `RouteOverviewCarScreen`.
3. `CarBridge.load` builds the snapshot from the active plan, vehicle, reservation and `SoCEstimatorEngine.safeAlternatives` (5).
4. `RouteOverviewCarScreen` paints a Geoapify static map (`CarMap`) and the sidebar; on car API <7 falls back to a list.
5. Actions: update battery (`SoCUpdateCarScreen` → same SoC engine, origin = plan origin, remaining = 60 %), reserve next free slot (RPC), navigate (`NavigationCarScreen`), charger list/details, reservation status, trip history, vehicle, settings.
6. Disconnect observer writes the DISCONNECTED row and clears the flag.
7. No sign-in, payment, meter reading or host control on the car surface.

---

## 10. Sign-out and account switching

1. Profile menu or Account page → confirm dialog.
2. `performSignOut`: remove `last_user_id`; `SupabaseAuth.signOut`; `repo.clearLocalData`; `AuthManager.clearCurrentUser`; `AppStateStore.reset`; `TripSessionStore.end`; `showSignIn`.
3. Next account sign-in sees a different `last_user_id`, so Room is wiped again before sync. Same account keeps cache for offline use.
4. Local device cache is not deleted by deleting the server account; app data must be wiped manually.

---

## 11. Offline behaviour

| Action | Offline result |
|---|---|
| Browse cached stations/reservations | works (Room) |
| Plan route | needs Geoapify for geometry; no cached plan for a new route |
| Battery correction | works from cached stations; audit row queued only locally |
| Reserve / cancel / settle / approve / resolve | **fails** with server-required message; no local confirmation |
| Chat/SOS | local row only until sync; no push channel |
| Car | snapshot from Room; reserve fails if server unreachable |

There is no offline write queue, no WorkManager, and no background sync. `SyncEngine` runs only when `MainActivity` calls it (sign-in and explicit refreshes).
