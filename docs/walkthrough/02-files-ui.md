# 02 — Files: UI (`feature/`, `ui/`, `MainActivity`) — 53 files

The UI is classic Views: `AppCompatActivity` + Fragments + `RecyclerView` adapters + Material 3 XML. There is no Compose, no ViewModel, no Navigation component, no Hilt. Screens call `AmperlyRepository` on a background executor and render in a main-thread callback; state that must survive tabs lives in `AppStateStore`/`TripSessionStore` or in the fragment instance (which is why tabs are hidden, not replaced).

Method declaration lines: `09-symbol-index.md`. Layout ids cited below are from the XML inventory.

---

## 1. `MainActivity.java` (1,260 lines)

The shell and the only `AppCompatActivity`. It implements `TripNavigationHost` and `TabBackStackHost`.

### Startup
`onCreate` (read in full): edge-to-edge, `activity_main`, insets, restore tab tags from `savedInstanceState`, `AmperlyRepository.getInstance`, back callback, toolbar (title disabled; the brand lock-up is the title), bottom nav reselect listener, deep link, `startBackend()`. Any exception is caught and falls back to `showSignIn()` rather than fabricated data.

### Back behaviour
`handleBack`: (1) fragment back stack → pop; (2) at home or no nav → `finish()`; (3) otherwise `goHome()`. `isAtHomeScreen` asks the **current tab by tag** (several tabs live in the container), treats SignIn as home, host tabs all as home, admin queue as home, consumer Discover as home.

### Insets and keyboard
`applyWindowInsets` pads the app bar by the status bar, the container when chrome is hidden, and the bottom nav by the navigation bar. `applyKeyboardInsets` reserves the IME height on the root (edge-to-edge means `adjustResize` alone does nothing), hides the bottom bar while the keyboard is open, and re-scrolls the focused field via `Ux.scrollIntoView`.

### Session
- `startBackend`: refuses to run if `SupabaseConfig` is unconfigured or the key looks secret; restores a stored session or shows sign-in.
- `restoreSession`: `SupabaseAuth.restoreSession` → `resolveOrCreateAppUser` → `accountRestrictionMessage` (signs out a banned/suspended account) → `onSignedIn`.
- `onSignedIn`: sets `AuthManager`, loads the active vehicle and its stored SoC, enables nav/chrome, applies ADMIN or CONSUMER role, toasts, warns if the profile write failed, then `syncAfterSignIn`.
- `syncAfterSignIn`: wipes Room when a **different** account signs in (same account keeps cache for offline), inserts the user row, runs `SyncEngine.syncNow`, and rebuilds the visible tab so pulled rows appear.
- `onSignedOut`/`performSignOut`: clears auth, `AppStateStore.reset()`, `TripSessionStore.end`, clears local data and returns to sign-in.

### Tabs and role
`buildNavigation(role, initialItemId)` clears the menu and builds:
- Host: Dashboard (`nav_host_dashboard`), Stations (`nav_host_add_station`), Bookings (`nav_host_bookings`), Profile (`nav_profile`).
- Admin: Queue (`nav_admin_queue`), Reports (`nav_admin_reports`) — **no Profile tab**.
- Consumer: Discover (`nav_discover`), Trips (`nav_route_plan`), Bookings (`nav_reserve`), Profile (`nav_profile`).

`landOnNavigation` lands on the requested tab if the new menu has it; otherwise the role default. Consumer default is Trips when `TripSessionStore.hasActive(this)`, else Discover. `selectNavigationItem` explicitly loads even when the id is already selected (needed after a sync rebuild). `switchRole` refuses a same-role switch and rebuilds landing on Profile; `applyRole` falls back to Consumer if `AuthManager.setRole` refuses.

### Tab lifetimes
Each tab screen is kept in the container and **hidden/shown** (`loadRoot`, `replaceTabRoot`); pages opened on top are filed under the tab name with `FragmentManager.saveBackStack` when leaving, restored with `clearBackStack`, and discarded on re-tap (`popCurrentTabPages`). This preserves a planned route, a running trip and half-typed forms across tab switches.

### Chrome, profile, deep link
- `showProfileMenu` opens Account (`account_page`), Vehicle, Safety, Sign out; sign-out is visible only when `SupabaseAuth.isSignedIn()`.
- `buildProfileBadge` inflates `view_profile_button` (initials/name/role), with an 8 dp end gutter holder; `refreshProfileBadge` re-renders after rename/role switch.
- `onCreateOptionsMenu` inflates `main_menu` (bell + profile action view); menu items are hidden while nav is off (sign-in).
- `handleDeepLink` recognises `amperly://auth-callback` and only toasts `auth_callback_return`; it never treats the intent as confirmation.
- `makeToolbarHome` wires the brand and empty toolbar area to `goHome` without stealing the profile badge/action menu.

---

## 2. `feature/` — 20 fragments

Line counts and layout ids are exact; behaviour is described from the fragment's wiring and the layout it inflates. Claims that could not be confirmed from a full body read are marked **[INFERRED]**.

### Auth

| File | Layout | Responsibility |
|---|---|---|
| `SignInFragment.java` (346) | `fragment_sign_in` (`signInTitleText`, `signInNameEdit`, `signInEmailEdit`, `signInPasswordEdit`, name/email/password input layouts, submit) | Sign in / create account toggle. Validates name/email/password via `ValidationUtils`, calls `SupabaseAuth.signInWithPassword`/`signUp`, handles `error_auth_invalid_credentials`, `error_auth_email_unconfirmed`, `error_auth_already_registered`, and calls `MainActivity.onSignedIn(user)` on success. If email confirmation is required, shows `auth_confirm_email` and stays on the page. Its own brand header is why `MainActivity.setChromeVisible(false)` hides the toolbar. |
| `AccountFragment.java` (407) | `fragment_account` (`accountAvatarText`, `accountNameText`, `accountEmailText`, `accountAuthorityText`, `editNameButton`, `roleChipGroup`, sync/status rows, sign-out) | Profile page. Edits display name (dialog), renders role chips, switches capacity via `MainActivity.switchRole`, shows sync status and sign-out. Sign-out uses the same confirm dialog/flow as the shell. Reachable as consumer/host Profile tab and as a root page from the profile menu. |

### Consumer

| File | Layout | Responsibility |
|---|---|---|
| `ChargerDiscoveryFragment.java` (692) | `fragment_charger_discovery` (`mapContainer`, `heroBatteryCard`, `heroBatteryText`, `vehicleSwitcherRow`, `heroBatteryProgress`, `updateVehicleButton`, station list) | Home. Shows the MapLibre map + approved/live stations, battery hero (estimate vs actual), vehicle switcher, list of stations with distance/price/connectors/verification. Tapping a station opens `ChargerDetailsFragment`. Battery update opens a number dialog, calls `SoCEstimatorEngine.applyAuthoritativeSocOverride`, saves the audit, updates `AppStateStore` and the safe-charger set. **The primary consumer entry point.** |
| `ChargerDetailsFragment.java` (497) | `fragment_charger_details` (`detailsNameText`, `detailsAddressText`, `availabilityText`, `freshnessText`, `totalPerKwhText`, `verificationText`, `meterGatingWarningText`, availability timeline, Reserve button) | Station page: tariff breakdown, verification level, live availability timeline, map, reserve CTA. Refuses reservation for `LEVEL_3_NO_VERIFIED_METER` (discovery only) and for paused/unapproved stations. Opens `ReservationFragment` with the station id. **[INFERRED]** for exact timeline interaction. |
| `ReservationFragment.java` (559) | `fragment_reservation` (`reserveStationText`, `chooseStationButton`, `bookingVehicleRow`, `portDropdown`, `slotDropdown`, `bookingForm`, price summary, Reserve button, "Your reservations" list) | Two modes: choose a station, or book a slot. Builds ports/slots via `AvailabilityEngine`, shows cancellation policy, calls `repo.createReservationConfirmed` (RPC) and handles `reserve_slot_taken`/`reserve_slot_in_past`/`reserve_slot_too_long`/`reserve_station_unavailable`/`reserve_server_*`. On success shows the booking code and opens `BookingQrFragment`. Lists the consumer's reservations with QR/check-in/chat/session actions. |
| `BookingQrFragment.java` (135) | `fragment_booking_qr` (`qrImageView`, `bookingCodeText`, `qrStationText`, `qrSlotText`, `goToSessionButton`) | Renders the booking code as a QR bitmap (ZXing/core? — the bitmap is generated locally; no library call was observed in the fragment header) and the slot summary; navigates to the active session. **[INFERRED]** on QR encoder. |
| `ActiveSessionFragment.java` (411) | `fragment_active_session` (`sessionStateText`, `sessionInfoText`, `liveKwhText`, `liveTimeText`, `liveCostText`, `startMeterEdit`, `endMeterEdit`, `captureStartButton`, `simulate...`, stop/bill button) | Live charging: check-in, start, simulated/manual meter readings, live kWh/time/cost, then stop-and-bill. Meter start must be captured before end; end < start is rejected (`session_invalid_reading`). Finalization calls the server RPC; if offline it shows `session_server_required`/`session_server_failed` and issues no receipt. Opens `ReceiptFragment` on success. |
| `ReceiptFragment.java` (242) | `fragment_receipt` (`receiptPaidBlock`, `receiptTitleText`, `receiptStationText`, `receiptPendingText`, `receiptContainer`, `receiptTotalText`, billing lines) | Server-issued receipt: energy, service, gateway, adjustment, total, payment status. Uses `item_billing_line`. Read-only; the client cannot edit amounts. |
| `RoutePlannerFragment.java` (1,066) | `fragment_route_planner` (`originText`, `originDetailText`, `setOriginOnMapButton`, `destinationEdit`, `destinationResolvedText`, `plannerVehicleText`, preference/exclusion controls, plan summary, stop list, Start navigation) | The largest screen. Origin = GPS or map pick; destination = autocomplete (`PlacesAutocomplete`, 300 ms/3 chars/5 results) or place dialog; vehicle/preference/corridor/reserve inputs; calls `GeoapifyRoutingClient` + `RoutePlannerEngine`; renders primary stops, backups, confidence, assumptions; saves `RoutePlan`+`RouteStop`s; starts `InAppNavigationFragment`; supports excluding/clearing stations and re-planning. **[INFERRED]** for individual control ids beyond the layout inventory. |
| `InAppNavigationFragment.java` (550) | `fragment_in_app_navigation` (`navMapContainer`, `navNextTurnText`, `navInstructionText`, `navRemainingText`, `navEtaText`, `navStatusText`, `navUpdateBatteryButton`, `navStopButton`) | Phone turn-by-turn: MapLibre route + position, next instruction, remaining distance/ETA, battery update, stop. `forActiveTrip(context)` is the factory `MainActivity` uses to restore a running trip. On stop it marks the plan complete and clears the active session. |
| `VehicleProfileFragment.java` (110) | `fragment_vehicle_profile` (`vehicleList`, `vehicleEmptyState`, `addVehicleButton`) | Lists vehicle profiles, marks the active one, opens `VehicleFormFragment`, switches active vehicle (repository clears other flags). |
| `VehicleFormFragment.java` (418) | `fragment_vehicle_form` (`makeEdit`, `modelEdit`, `variantEdit`, `yearEdit`, `plateEdit`, `capacityEdit`, `connectorDropdown`, `maxAcEdit`, `maxDcEdit`, efficiency/health/min-max SoC fields) | Create/edit a vehicle. Validates numeric ranges; saves locally then remotely. Capacity/connector feed the planner and SoC engines. |
| `HostChatFragment.java` (255) | `fragment_host_chat` (`maskedDisclaimerText`, `threadsChipGroup`, `threadTitleText`, `threadExpiryText`, `messagesRecyclerView`, `quickQuestionsRow`) | Reservation-scoped chat for both parties: thread chips, messages (`item_chat_message`), quick questions, masked-number disclaimer, expiry, report/block. Uses `ChatManager`; no raw phone numbers. |
| `SafetySOSFragment.java` (283) | `fragment_safety_sos` (`sosNoticeText`, `sosButton`, `sosStatusText`, `contactsRecyclerView`, contact name/phone fields, add button) | SOS page: explains what is shared, triggers a `SafetyEvent` with live-location flag and expiry, manages `TrustedContact`s (`item_contact`, call/delete). It does **not** call emergency services; the copy says so. **[INFERRED]** for the exact dispatch side effect. |

### Host

| File | Layout | Responsibility |
|---|---|---|
| `HostDashboardFragment.java` (244) | `fragment_host_dashboard` (`hostNameText`, `statsIncomeText`, `statsDisputesText`, `statsReservationsText`, `statsUtilizationText`, `analyticsContainer`, empty state) | Host home: analytics from `HostAnalyticsEngine` (sessions, energy, revenue, utilization with its estimate note, disputes, reservations), station cards, add-station CTA. |
| `HostStationsFragment.java` (142) | `fragment_host_stations` (`hostStationsList`, empty state, `addStationButton`) | Host's stations as cards (`item_station_card`): pause/resume, edit, delete (muted delete style), open registration. |
| `RegisterStationFragment.java` (558) | `fragment_register_station` (`stationNameEdit`, `addressEdit`, `latitudeEdit`, `longitudeEdit`, `stationMapContainer`, `useGpsButton`, `choosePlaceButton`, tariff/service/gateway fields, connector/power/port fields, verification level, access rules, hours) | Create/edit a charger. GPS or geocoded address sets the pin; map picker; validates tariff/connectors/ports; saves as `PENDING` for admin approval. A host cannot self-approve (server trigger). |
| `HostBookingsFragment.java` (127) | `fragment_host_bookings` (`hostBookingsRecyclerView`, empty state) | All reservations for the host's stations, grouped/rendered by `HostBookingCardAdapter` (`item_host_booking`): code, status, driver, slot, chat, check-in/session actions. |

### Admin

| File | Layout | Responsibility |
|---|---|---|
| `AdminDashboardFragment.java` (629) | `fragment_admin_dashboard` (`platformAnalyticsText`, `adminQueueSection`, `pendingStationsRecyclerView`, `adminReportsSection`, `adminConsumerReports...`, dispute/report lists) | Two sections selected by `ARG_SECTION` (`SECTION_QUEUE`, `SECTION_REPORTS`). Queue: pending stations (`item_admin_station`) with approve/reject (calls `decide_station_approval`), reports and disputes. Reports: consumer reports (`item_report`), dispute resolution (`item_dispute`: refund, freeze payout, warning/fine/suspend/ban), enforcement via `apply_host_enforcement`. Admin actions are the only path to those RPCs. |

### Common

| File | Layout | Responsibility |
|---|---|---|
| `NotificationsFragment.java` (61) | `fragment_notifications` (`notificationsRecyclerView`, empty text) | Inbox list (`item_notification`), unread dot, mark-read on tap; opened from the top-bar bell and the Account page. |

---

## 3. `ui/` — 18 files

### `Ux.java` (289 lines)
Static UI utilities: `toast`, `error` (long toast/snackbar), `scrollIntoView(View)`, keyboard hide/show, dp→px, and small view helpers used across fragments. `MainActivity` uses `Ux.toast/error/scrollIntoView`; it is the only place that turns a message key into a toast consistently.

### Adapters — 13 files
All are `RecyclerView.Adapter` subclasses with a `ViewHolder`; they bind entity/view-model rows and expose click callbacks. No adapter performs I/O.

| Adapter (lines) | Item layout | Binds |
|---|---|---|
| `StationAdapter` (291) | `item_station` | discovery list: name, price, connectors, type, distance, address, availability, freshness, verification badge |
| `StationCardAdapter` (119) | `item_station_card` | host station management: name, status, address, meta, pause/edit/delete |
| `ReservationAdapter` (130) | `item_reservation` | consumer bookings: station/status/slot/code/amount + QR, check-in, message |
| `HostBookingCardAdapter` (151) | `item_host_booking` | host bookings: code, status, station, driver, slot, chat, actions |
| `SessionAdapter` (101) | `item_session` | session history: station/status/meta/kWh/total + receipt/dispute |
| `RouteStopAdapter` (147) | `item_route_stop` | planner stops: sequence, name, badge, detail, reason, reserve |
| `VehicleCardAdapter` (123) | `item_vehicle_card` | vehicle list: name, active badge, meta/stats, Use |
| `PendingStationAdapter` (101) | `item_admin_station` | admin queue: name/host/submitted/meta + approve/reject |
| `DisputeAdapter` (191) | `item_dispute` | reason/meta/notes/response/evidence/enforcement + refund/freeze/warn/fine/suspend/ban |
| `ReportAdapter` (227) | `item_report` | report card/type/status/reporter/target/date + actions |
| `ChatMessageAdapter` (97) | `item_chat_message` | message text/meta/warning, own-vs-other alignment |
| `ContactAdapter` (83) | `item_contact` | trusted contact name/phone + call/delete |
| `NotificationAdapter` (81) | `item_notification` | unread dot/title/message/time |

### Dialogs — 4 files

| Dialog (lines) | Layout | Purpose |
|---|---|---|
| `PlaceSearchDialog` (79) | `dialog_place_search` (`placeSearchEdit`) | Destination/address search; drives `PlacesAutocomplete`, shows `item_place_suggestion`, returns a resolved place. |
| `ReportDialog` (120) | `dialog_report` (`reportTypeDropdown`, `reportDetailsEdit`) | Report type + description for a station/session/user; writes `Report`. |
| `MeterEvidenceDialog` (74) | `dialog_meter_evidence` (`meterStartEdit`, `meterEndEdit`, `meterNoteEdit`, header) | Manual meter evidence entry for a session; validates end ≥ start; feeds `MeterReading`. |
| `VehicleSwitcherDialog` (109) | reuses `item_vehicle_card`/list | Selects the active vehicle from discovery; repository clears other active flags. |

Two more dialogs exist as generic layouts: `dialog_edit_name` (`editNameInput`) and `dialog_input_number` (`numberInput`); they are inflated directly by `AccountFragment`/battery update rather than by dedicated classes.

---

## 4. UI conventions and gaps

- Every screen inflates a single XML layout; there is no data binding or view binding — `findViewById` throughout.
- Error strings come from `strings.xml`; adapters receive already-formatted values.
- The bottom navigation is built **programmatically** per role in `MainActivity.buildNavigation`, using stable ids from `values/ids.xml`.
- No screen uses `ViewModel`, `LiveData` observation, or `SavedStateHandle` directly. Rotation relies on fragment retention plus `MainActivity` restoring tab tags; a fragment's transient field (e.g. a half-typed plan) is lost if the process dies, not on tab switch.
- Accessibility: content descriptions exist on icon-only controls; touch targets use `amp_touch_target` (48 dp). No automated accessibility test exists.
