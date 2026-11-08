# Amperly — Flutter phone UI

This folder is the **embedded Flutter module** for the handset experience. It is
not a separate app: it is a `:flutter` library inside the native Amperly Android
application at the repository root.

## One APK, two surfaces

| Surface | Technology | Entry point |
|---|---|---|
| Handset | Flutter (this folder) | `app/.../FlutterPhoneActivity.java` |
| Android Auto | Native Java + Car App Library | `app/.../car/AmperlyCarAppService.java` |

Android Auto cannot host Flutter: the Car App Library draws templates in the
projection host and has no Flutter embedding path. The car service therefore
stays Java and keeps its Room cache, repository and engines. The two surfaces
share one application id, one Supabase project and one APK.

Configuration is not duplicated. The Java build already reads
`SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`, `GEOAPIFY_API_KEY` and
`MAP_STYLE_URL` from the root `local.properties`; `FlutterPhoneActivity` hands
those values to Dart over `com.amperly.app/native`. A secret Supabase key is
refused before the Flutter app starts, exactly as on the Java side.

## Build and run

```bash
cd flutter_app && flutter pub get && cd ..
./gradlew :app:assembleDebug
```

The APK is `app/build/outputs/apk/debug/app-debug.apk`. It contains the Flutter
phone UI and the Java Android Auto service. Install and launch it normally; the
launcher opens the Flutter surface.

Requirements:

- Flutter 3.47.x / Dart 3.13.x. This working copy uses `.tools/flutter`.
- Android SDK platform 36 and a JDK 17+ (the Android Studio JBR works).
- Root `local.properties` with the same keys the Java app already uses.
- Flutter 3.47's Gradle plugin still uses the legacy AGP extension API, so the
  root `gradle.properties` sets `android.newDsl=false` and
  `android.builtInKotlin=false`. Do not enable those flags until the Flutter
  plugin supports them.

To run only the Flutter surface on a standalone module host (no car, useful for
UI work), the Dart side still accepts `--dart-define-from-file=env.json` as a
fallback when the native channel is absent:

```bash
cd flutter_app
cp env.json.example env.json
flutter run --dart-define-from-file=env.json
```

`env.json` is gitignored. Never put an `sb_secret_` or `service_role` key in it.

## What is implemented

**Phase 1 — account layer**

- Real Supabase email/password sign-in and account creation. The display name
  is sent as user metadata, matching the Java sign-up payload.
- Email-confirmation projects are handled honestly: the screen asks the person
  to confirm the address and sign in, instead of pretending a session exists.
- Session restore through Supabase's auth stream and the existing `go_router`
  redirect guard. A restored encrypted session skips the sign-in screen.
- One session store for both surfaces. On Android, Supabase's `LocalStorage` is
  backed by the Java Keystore preferences through `NativeSessionBridge`; the
  Java car layer reads the same tokens. A refresh performed by the car is
  handed to a running Flutter client over the bridge, so it can adopt the new
  token instead of presenting an already-rotated refresh token. Standalone
  Flutter runs fall back to `flutter_secure_storage`.
- Sign-out ends the session and clears the Java `AuthManager`, shared state,
  active trip and Room cache, so the next person cannot inherit the car's data.
- The Phase 0 design system: feature-first folders, bundled fonts, explicit
  light/dark themes, shared components, custom icons, illustrations, the
  debug-only gallery, `UserMessages` and the native-config loader.

**Phase 2 — data and domain**

- All 23 Supabase table models as Freezed classes, with unknown status values
  retained as strings rather than crashing a row parse.
- Typed repositories for the profile, vehicles, stations, reservations,
  sessions, notifications and the server RPCs.
- Pure Dart ports of the availability, reservation, billing, meter, route
  planner, SoC, trip-time, enforcement, analytics, chat, payment, visibility and
  role-guard engines.
- Geoapify place, geocoding and routing clients with parsing, caching and
  request pacing.

**Phase 3 — consumer catalogue**

- The signed-in Auth account resolves to its real `public.users` profile.
- Blocked accounts see a restricted-account screen and a sign-out action, never
  the catalogue.
- **Discover** reads approved, unpaused stations and their real ports in two
  grouped queries. It shows port status and its age, never a live-hardware
  claim. Filters cover all chargers, the active vehicle's connector, DC fast and
  verified-meter chargers.
- **Charger details** reads the live station row again, lists ports, opens the
  published fee breakdown and states clearly when a station has no verified
  meter.
- **Profile** shows the real identity, account type, verification state, active
  vehicle and a confirmed sign-out.

**Phase 4 — vehicle garage**

- **My vehicles** lists every saved vehicle with its registration, connector,
  usable capacity, efficiency and estimated range. The active car is marked and
  every other card can be switched into use.
- **Add/edit vehicle** ports the phone form: identity, connector, battery and
  charging limits, arrival reserve and target charge. The same draft object
  validates the fields, the derived planning range and the final row.
- Saving writes the whole garage in one Supabase upsert, with exactly one active
  row. Deleting the active vehicle promotes the next one instead of leaving
  range and compatibility checks without a profile.
- The garage is reachable from **Profile** and from the vehicle line on
  **Discover**. The active vehicle remains the one used by compatibility
  filters.

**Phase 5 — trip planner**

- **Plan a trip** draws a real Geoapify raster map of the same OpenStreetMap
  style as the car surface. The starting point is the device's actual GPS fix
  or a pin the driver taps, never a default city. Permission and service
  failures explain the next step instead of inventing a coordinate.
- Destination search uses Geoapify autocomplete with debounce and request
  sequencing. Free-typed destinations resolve through forward geocoding. A
  build without a Geoapify key says the map is not configured and keeps the
  screen honest rather than showing a fake map.
- The active vehicle supplies usable capacity, efficiency, connector and
  arrival reserve. The dashboard battery reading is required; Amperly never
  guesses a starting SOC.
- A Geoapify road route supplies distance and drive time, then the shared
  `RoutePlannerEngine` plans compatible chargers inside the selected corridor
  under the 45 km/h policy, arrival reserve and stop preference. The result
  shows the recommended stop, backups, estimated SOC and energy, directions,
  assumptions and excluded chargers.
- The plan is not persisted yet; route-plan storage is a later phase.

**Phase 6 — consumer bookings**

- **Reserve** appears on a charger with a verified meter and opens the booking
  form. Stations without metering stay read-only, because they cannot bill
  energy.
- The form reads the charger, its live ports, its published
  `availability_schedules` and the caller's own reservations. It offers only
  available, connector-compatible ports and 90-minute slots inside the host's
  opening hours for the next three days. Slots are generated by the shared
  `AvailabilityEngine`; the screen never invents a schedule.
- The price preview uses the station's real tariff, service fee and gateway fee,
  with the same 90-minute/75% energy estimate as the Java booking flow. It says
  plainly that no payment is collected in this build.
- Submitting calls the server's `create_reservation` RPC, never a direct table
  insert. A slot taken between the preview and the tap is reported in plain
  language and availability reloads; the client does not retry or fake a hold.
- **Your bookings** lists server-confirmed reservations with status, slot, port,
  booking code and the no-payment note. Reserved bookings can be cancelled
  through `cancel_reservation` after a confirmation that shows the free/late
  window.
- **Booking code** shows the code and a real QR payload built from the confirmed
  reservation, plus the station, slot and fees. It is reachable from the
  bookings list, and **Your bookings** is reachable from Discover.

**Phase 7 — charging sessions**

- An active booking opens a **charging session** from the booking code or the
  bookings list. The screen shows the booking, port, slot and station meter
  level before any meter reading is accepted.
- **Check in** asks for the starting reading on the station meter. It opens a
  server session row with zero billing and moves the reservation to
  `CHECKED_IN`; a failed booking-status update is reported without discarding
  the session, which settlement can still complete.
- **Start charging** moves the session and booking to `CHARGING`. The ending
  reading is entered by hand when charging stops. A local `BillingEngine`
  preview shows the energy, service, gateway and total figures, but the server
  recomputes them from the two readings.
- Settlement calls `finalize_charging_session` only. That function writes the
  completed session, meter reading and issued invoice, closes the reservation
  and frees the port. The screen then shows the itemised receipt, including the
  starting and ending readings, verified energy and a clear no-payment notice.
- **Charging history** lists every server session, with active sessions and
  completed receipts. It is reachable from Discover. Cancellation is now
  limited to a `RESERVED` booking; a checked-in or charging session must be
  settled instead.
- Readings are labelled as hand-entered from the station meter, not as a live
  hardware feed. No payment is collected in this build.

**Phase 8 — consumer messaging**

- **Messages** lists the signed-in consumer's real conversations from
  `communication_threads`, newest activity first, with the other participant,
  the latest booking's station, a preview of the last line and the thread's
  expiry. It is reachable from Discover.
- **Message host** on a booking finds that booking's station owner and opens the
  pair's conversation. The first booking creates a thread; a later booking with
  the same host reuses it, refreshes the booking context and expiry, and keeps
  the existing history together.
- The thread reads `chat_messages` through a live Supabase stream and still
  shows its current rows when Realtime is unavailable. Pull to refresh reloads
  the transcript.
- Sending writes a sanitized message. Phone numbers are masked, an off-platform
  payment request is flagged with an in-app warning, and a closed, blocked or
  expired conversation never offers a composer. Quick questions fill the same
  composer without inventing a reply.
- Free-text chat is phone-only; Android Auto remains the native Java surface and
  does not expose it.

Host and admin surfaces are still to be ported phase by phase. There is no demo
or seed data.

## Checks

```bash
cd flutter_app
../.tools/flutter/bin/flutter analyze
../.tools/flutter/bin/flutter test
```

## Structure

```
lib/
  app/          bootstrap, router, themes, debug gallery
  core/         env, errors, formatting, geo, location, shared widgets, strings
  data/         Supabase client, 23 models, Geoapify clients and map config,
                repositories
  domain/       policy constants and the pure engines
  features/     auth and session, consumer catalogue, vehicle garage, trip
                planner, bookings, charging sessions, home gate, gallery
assets/fonts/   Fraunces and Plus Jakarta Sans
test/           env, copy, formatting, theme, models, engines, catalogue,
                vehicle, trip validation, booking, session and chat rules
                tests
```

## Known limits

- Flutter is still an incomplete phone product. The host/admin desks are later
  phases. The Java fragments remain as the behavioural reference but are no
  longer the launcher.
- Bookings and charging sessions have not been created against a staging
  Supabase project in this working copy. The `create_reservation` /
  `cancel_reservation` / `finalize_charging_session` RPCs, the session insert
  policies, slot lock, RLS visibility and late-fee record still need an
  end-to-end run. No payment is collected in this build.
- Chat threads and messages are written directly to the two chat tables;
  there is no chat RPC. Pair lookup, thread reuse, message inserts and Realtime
  delivery still need a staging run. `schema.sql` adds `chat_messages` to the
  standard `supabase_realtime` publication when that publication exists.
- No device/emulator or Android Auto Desktop Head Unit run has been done in
  this working copy. Build, `flutter analyze`, `flutter test` and the combined
  APK package are the checks; real Supabase sign-in, RLS, catalogue reads, GPS
  permission, Geoapify tiles and live route planning have not been exercised on
  a device here.
- The catalogue reports host-published port status. It does not query other
  users' reservations, because Row Level Security hides them, so it never
  claims a station-wide booking calendar.
- Vehicle writes use the existing `vehicles` table and its own-row policy. The
  one-active-row invariant is enforced by a single multi-row upsert from the
  client; it has not been exercised against a staging Supabase project here.
- Trip plans are not persisted to Supabase yet; a plan lives only on the
  screen. Offline cache, payments and host/admin desks are later phases.
  Android Auto remains native Java, not Flutter.
