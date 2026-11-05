# 06 — Configuration, build and deployment

Everything below is from the build files, the manifest, the resource configs and `local.properties` **key names only** (no secret values are reproduced).

---

## 1. Project shape

- Single Android application module `:app`; `settings.gradle.kts` (26 lines) includes it and declares repositories.
- Root `build.gradle.kts` (3 lines) applies the plugin declarations from the version catalog; the real build logic is in `app/build.gradle.kts` (202 lines).
- Kotlin DSL throughout; Java 11 source/target (as configured in `app/build.gradle.kts`).
- `gradle/libs.versions.toml` (63 lines) declares plugin/library versions, but `app/build.gradle.kts` also pins many dependencies as literal coordinates. The catalog is therefore not the single source of truth (Q11).
- Gradle wrapper: `gradle/wrapper/gradle-wrapper.properties` (9 lines) + `gradlew`/`gradlew.bat`; `gradle/gradle-daemon-jvm.properties` (12 lines) pins the daemon JVM.

## 2. SDK and identity

| Setting | Value |
|---|---|
| `applicationId` | `com.amperly.app` |
| `compileSdk` | 35 |
| `targetSdk` | 35 |
| `minSdk` | 24 |
| `versionName` / `versionCode` | 4.6.0 / 26 (`app/build.gradle.kts`) |
| Java source/target | 11 |
| Build features | `buildConfig = true`, `viewBinding` not used by code |

## 3. BuildConfig and secrets

`app/build.gradle.kts` reads these from `local.properties`, falling back to environment variables of the same name, and exposes them as `BuildConfig` fields:

| Key (name only) | Used by |
|---|---|
| `SUPABASE_URL` | `SupabaseConfig` base URL |
| `SUPABASE_PUBLISHABLE_KEY` | `SupabaseConfig` `apikey` / bearer bootstrap |
| `GEOAPIFY_API_KEY` | `MapConfig`, geocoding, routing, static map |
| `MAP_STYLE_URL` | MapLibre style (OSM-Bright) |
| `sdk.dir` | Android SDK location (standard) |
| `KEYSTORE_*` (file, password, alias, key password) | release signing config |

Rules enforced at build time: the publishable key must not look like a Supabase **secret** key (`sb_secret_…` / `service_role`); if it does, the build fails. At runtime `SupabaseConfig.looksLikeSecretKey()` refuses to start sync and logs a clear error. `local.properties` is gitignored; the release keystore (`keystore/amperly-release.jks`) is gitignored too and is present only on this machine.

`BuildConfig` values are baked in at compile time: changing a key requires a rebuild, not just a restart (documented in `supabase/README.md`).

## 4. Dependencies (as used by code)

- AndroidX AppCompat, Material 3, ConstraintLayout, RecyclerView, Fragment, Activity, Lifecycle.
- Room runtime/compiler (23 entities, v6).
- Android Car App Library (`androidx.car.app`), navigation templates.
- MapLibre Android SDK (phone map).
- OkHttp (Supabase + Geoapify + static map).
- AndroidX Security Crypto (EncryptedSharedPreferences).
- JUnit 4 for JVM tests; AndroidX test runner/espresso for the single instrumented test.

`libs.versions.toml` contains entries not used by the build and versions that differ from the literal pins (Q11).

## 5. Manifest contract

`app/src/main/AndroidManifest.xml` declares:

- **Permissions**: internet; fine and coarse location (map centring, GPS origin, SOS live-location flag). No camera, contacts, SMS, background-location or foreground-service permission was observed.
- **`MainActivity`**: launcher, exported, handles deep links via `onNewIntent`, theme `Theme.Amperly`, soft-input behaviour handled by the shell.
- **`AmperlyCarAppService`**: exported, car-app intent filter, category `androidx.car.app.category.NAVIGATION`, `automotive_app_desc` meta-data (`template`).
- **Deep link**: scheme `amperly`, host `auth-callback`; treated as “user returned”, never as email-confirmation proof.
- **Security**: `android:allowBackup="false"`, `android:usesCleartextTraffic="false"` (API 24–27), `networkSecurityConfig` denying cleartext for all domains, backup/data-extraction rule files excluding everything.
- **No** Google Maps API key meta-data, no FCM service, no WorkManager initializer, no Application subclass.

## 6. Supabase setup order

From `supabase/README.md` (306 lines):

1. Run `supabase/schema.sql` in the SQL editor (tables → functions → RLS → policies → triggers → backfill). Ends with 23 tables, all RLS-enabled; the final query must show an `app_user_id` for every Auth account.
2. On an existing project, run `security_hardening.sql` (idempotent) to close self-approval/forgery/self-resolution holes.
3. Create the admin with `create_admin.sql` (edit the placeholder password first; the file refuses the placeholder). Email defaults to `admin@amperly.app`.
4. Put `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY` in `local.properties`; rebuild.
5. Create Auth users in the dashboard, **Auto Confirm** on (or configure SMTP; the built-in sender only mails project team members). The `auth.users` trigger creates the profile.
6. There is **no seed data**; hosts add stations in the app and an admin approves them.
7. Deleting an Auth user cascades the app data; deleting `public.users` alone does not.

Publishable key is safe only because RLS is enabled on every table. Never use `sb_secret_`/`service_role` in the app.

## 7. Geoapify setup

One key powers geocoding, autocomplete, routing and the car static map. Geocoding is restricted to `countrycode:in`. If the key is missing, `MapConfig.isConfigured()` is false: the phone shows `map_setup_required`, the car draws no map, and routing/place search fail with `error_map_unavailable` / `error_place_search`. Attribution (`map_attribution`, static-map `attribution=default`) is part of the UI.

## 8. Android Auto

- Test with the **Desktop Head Unit** (`adb forward tcp:5277 tcp:5277`, then `desktop-head-unit`), or a real car head unit.
- The service uses `HostValidator.ALLOW_ALL_HOSTS_VALIDATOR` (needed for DHU/sideload). Play review for a navigation-category app expects the default allow-list; this is a release blocker, not a runtime bug (Q6).
- Car API level matters: `MapWithContentTemplate` requires level 7; older hosts get the list fallback.
- No automotive hardware, OCPP or charger telemetry exists; the “meter” is `MeterSimulator`/manual entry.

## 9. Build, test and release commands

```bash
./gradlew assembleDebug          # debug APK
./gradlew test                   # 24 JVM test classes
./gradlew connectedAndroidTest   # 1 instrumented template test (device/emulator)
./gradlew assembleRelease        # requires KEYSTORE_* in local.properties
./gradlew lint                   # no lint baseline checked in
```

There is **no CI configuration** in the repository (no `.github/workflows`, no GitLab/Jenkins file) and no `lint.xml`/baseline. Release signing is local-only; nothing is deployed by the repository. No Play Store metadata, Fastlane, or versioning script exists.

## 10. Environment checklist for a new machine

1. JDK 17, Android SDK 35, build-tools matching.
2. `local.properties` with `sdk.dir` + the four app keys + signing keys if releasing.
3. Supabase project with `schema.sql` (+ hardening + admin) applied.
4. Geoapify key with Static Maps, Geocoding and Routing enabled.
5. `./gradlew test` green; install debug; sign in with an Auto-Confirmed Auth user.
6. For car: DHU + `automotive_app_desc`; for maps on car, the same Geoapify key.

## 11. Configuration drift

- `README.md` says Room v5; code is v6 (Q3).
- `README.md` references `AmperlyApplication.java`; no such file exists (Q4).
- `README.md`/`MAPS_MIGRATION.md` describe a Google Maps migration; the code uses MapLibre + Geoapify and contains no Google Maps/Navigation SDK (Q5).
- Some comments still say “seeder” although no seeder exists (Q9).
- The version catalog and literal dependency pins disagree (Q11).
