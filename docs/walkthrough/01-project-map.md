# 01 — Project map

> Scope: the working tree at `C:\Users\ACER\Amperly` on 2026-11-04. Every statement below is grounded in
> the files cited. Anything not visible in code is marked **NOT VISIBLE IN CODE**; inference is marked
> **[INFERRED]**.

## 1. What the project is

Amperly is a **single-module Android application written in Java** for reserving and managing existing
EV chargers. It is not a web app and it has no server code in this repository beyond SQL schema files.
The app talks to a hosted **Supabase/Postgres** project over HTTPS (PostgREST + GoTrue) and caches rows
in a local **Room** database. Maps are rendered by **MapLibre Native** using a Geoapify-hosted vector
style; address search, reverse geocoding and road routing are **Geoapify** HTTP APIs. A projected
**Android Auto** surface (Car App Library) reads the same in-process state as the phone.

Primary sources: `README.md` §1–§12, `app/build.gradle.kts`, `app/src/main/AndroidManifest.xml`,
`supabase/README.md`, `supabase/schema.sql`.

### Product posture (important for reading the code)

- The repository ships **no demo data and no seed scripts**. The app boots to sign-in; all content is
  the signed-in account's rows filtered by Postgres Row Level Security (`README.md` §7,
  `SECURITY_REVIEW.md` residual risk 8).
- **No payments are collected.** `PaymentManager` is an in-repo sandbox; bookings are free holds and
  invoices are issued, not charged (`README.md` §1, `PITCH.md` "What is real, and what is not").
- **No charger hardware integration / OCPP / live telemetry.** Availability is schedule- and
  reservation-derived, and meter values are simulated or manually entered and labelled as such
  (`README.md` §1, §11).
- **Estimates are labelled**; billing is only allowed from a verified meter (`README.md` §4).

## 2. Tech stack and exact versions

| Layer | Choice | Version / evidence |
|---|---|---|
| Language | Java, source/target 11 | `app/build.gradle.kts` `compileOptions` (JavaVersion.VERSION_11) |
| Build | Gradle 9.6.0 wrapper, Android Gradle Plugin 9.4.1 | `gradle/wrapper/gradle-wrapper.properties`, `gradle/libs.versions.toml` (`agp = "9.4.1"`) |
| SDK | compileSdk 35, targetSdk 35, minSdk 24 | `app/build.gradle.kts` `android {}` |
| App identity | `com.amperly.app`, versionCode 26, versionName 4.6.0 | `app/build.gradle.kts` `defaultConfig` |
| UI | AppCompat 1.6.1, Material 1.11.0, ConstraintLayout 2.1.4, RecyclerView 1.3.2, Fragment 1.6.2, Activity-KTX 1.8.2 | `app/build.gradle.kts` dependencies |
| Car | Android for Cars App Library `androidx.car.app:app:1.4.0` | `app/build.gradle.kts` |
| Persistence | Room runtime/compiler 2.6.1, DB version **6**, 23 entities + 23 DAOs, `fallbackToDestructiveMigration` + `MIGRATION_5_6` | `AmperlyDatabase.java` |
| Backend | Supabase (Postgres + RLS + PostgREST + GoTrue) over OkHttp 4.12.0 (Retrofit 2.9.0/Gson 2.10.1 are declared in the catalog) | `gradle/libs.versions.toml`, `data/remote/*` |
| Maps | MapLibre Native Android 11.13.5 | `libs.versions.toml` (`maplibre = "11.13.5"`) |
| Places / routing | Geoapify HTTP APIs (no SDK) | `core/places/PlacesAutocomplete.java`, `core/routing/GeoapifyRoutingClient.java` |
| Location | `play-services-location` 21.2.0 (fused provider) | `app/build.gradle.kts`, `core/location/LocationProvider.java` |
| QR | ZXing core 3.5.3 | `app/build.gradle.kts` |
| Crypto | `androidx.security:security-crypto:1.1.0-alpha06` for session tokens | `app/build.gradle.kts`, `data/remote/SupabaseAuth.java` |
| Tests | JUnit 4.13.2 (JVM unit tests); Espresso 3.7.0 + AndroidX JUnit 1.3.0 (instrumented) | `libs.versions.toml` |
| Navigation/lifecycle libs | AndroidX Navigation 2.7.7, Lifecycle 2.7.0, SwipeRefreshLayout 1.1.0 (declared) | `app/build.gradle.kts`; see §7 for actual usage |

## 3. Annotated directory tree

Only source/config files are shown; `build/`, `.gradle/`, `.git/`, `.idea/` are generated or local.
Line counts are from `00-manifest.md`.

```text
Amperly/
├── README.md                     (398)  product + architecture + setup reference
├── PITCH.md                      (160)  short demo/pitch script (untracked at audit time)
├── SECURITY_REVIEW.md            (168)  fixed issues and residual risk
├── MAPS_MIGRATION.md              (76)  Google Maps → MapLibre/Geoapify migration notes
├── build.gradle.kts                (3)  root build file, AGP plugin alias only
├── settings.gradle.kts            (26)  repos, rootProject.name="Amperly", include(":app")
├── gradle.properties              (16)  JVM args, configuration cache on
├── gradlew / gradlew.bat     (251/94)  wrapper scripts
├── gradle/
│   ├── libs.versions.toml         (63)  version catalog (many deps are declared here but app/build.gradle.kts pins literals)
│   ├── gradle-daemon-jvm.properties (12) toolchain resolver config
│   └── wrapper/                   ...   Gradle 9.6.0 wrapper (jar is binary)
├── local.properties               (15)  machine-specific secrets (gitignored): keys only, values not reproduced
├── keystore/amperly-release.jks         release keystore (binary, gitignored by /keystore)
├── app/
│   ├── build.gradle.kts          (202)  app config, BuildConfig secrets, signing, dependencies
│   └── src/
│       ├── main/
│       │   ├── AndroidManifest.xml (112) permissions, MainActivity, car service, backup/cleartext policy
│       │   ├── keepRules/rules.keep (11) R8 keep rules (minification is off)
│       │   ├── java/com/amperly/app/   157 Java files, 27,286 lines (see §4)
│       │   └── res/                    120 files, 115 XML + 5 fonts (see §5)
│       ├── test/java/...               24 JVM test files, 2,741 lines
│       └── androidTest/java/...         1 instrumented test, 26 lines
├── supabase/
│   ├── schema.sql               (2447)  full schema, RLS, triggers, RPC functions
│   ├── security_hardening.sql    (173)  additional hardening migration
│   └── README.md                 (306)  schema/roles/settlement contract
└── docs/walkthrough/                    this audit (created by this task)
```

## 4. Java package map (157 main-source files)

Counts are source files per package; details are in `02-files-*.md`.

| Package | Files | Responsibility |
|---|---|---|
| `com.amperly.app` (root) | 1 | `MainActivity` — role shell, bottom tabs, per-tab back stacks, deep-link handling |
| `car` | 4 | Car App Service/session, bridge to shared state, screen factory |
| `car.screen` | 10 | Driver-safe templates (map, navigation, list, details, SoC, reservation, history, vehicle, settings) |
| `communication` | 1 | `ChatManager` — masking, sanitising, thread lifecycle |
| `core.common` | 8 | constants, formatters, geodesy, Geoapify error text, map config, request tokens, user-facing error mapping, validation |
| `core.location` | 1 | fused location with explicit "unavailable" path |
| `core.map` | 4 | MapLibre panel, touch container, marker model, visibility rule |
| `core.nav` | 7 | navigation provider seam, Geoapify implementation, state, route progress, navigation hosts |
| `core.places` | 3 | Geoapify autocomplete, response parser, reverse/forward geocoder |
| `core.routing` | 4 | Geoapify routing client, route model, route cache, request throttle |
| `core.security` | 2 | `AuthManager` (account + acting role), `RoleGuard` (client-side rule mirror) |
| `core.state` | 3 | in-memory shared state (`AppStateStore`), persisted SoC (`SocStore`), persisted trip (`TripSessionStore`) |
| `data.local` | 1 | `AmperlyDatabase` (Room v6) |
| `data.local.dao` | 23 | one DAO per entity |
| `data.local.entity` | 23 | Room entities mirroring Postgres tables |
| `data.remote` | 8 | Supabase config/client/api/auth/rest, sync engine, reconciler, table map |
| `data.repository` | 1 | `AmperlyRepository` — the single data hub (1,935 lines) |
| `domain.enums` | 5 | status/connector/verification/role enums (partly unused; see quality report) |
| `engine.admin` | 1 | enforcement escalation policy |
| `engine.analytics` | 1 | host/platform analytics maths |
| `engine.availability` | 1 | bookable slot generation and conflicts |
| `engine.billing` | 1 | meter-first bill, cancellation/refund maths |
| `engine.booking` | 1 | reservation validation, price preview, booking code |
| `engine.meter` | 1 | simulated cumulative meter |
| `engine.routing` | 2 | corridor/multi-stop planning; trip-time maths |
| `engine.soc` | 1 | SoC estimation and authoritative-override recalculation |
| `feature.admin` | 1 | admin queue + reports screen |
| `feature.auth` | 2 | sign-in/sign-up, account/profile |
| `feature.common` | 1 | notifications list |
| `feature.consumer` | 12 | discovery, details, route planner, navigation, vehicle garage/form, reservation, QR, active session, receipt, SOS, host chat |
| `feature.host` | 4 | host dashboard, stations, station registration, bookings |
| `payment` | 1 | sandbox payment manager |
| `ui` | 1 | `Ux` shared view helpers |
| `ui.adapter` | 13 | RecyclerView adapters |
| `ui.dialog` | 4 | meter evidence, place search, report, vehicle switcher dialogs |

## 5. Resources

`app/src/main/res/` contains 115 XML files: 45 layouts (1 activity, 20 fragments, 18 items, 5 dialogs, 1 view), 48 drawables (icons and
shape/background resources), 4 color state lists, 2 menus, 4 mipmap adaptive-icon files, 8 values files
(`colors`, `dimens`, `ids`, `strings` 778 lines, `styles` 487, `themes` 120, plus `values-night` colors and
themes), and 4 XML config files (`automotive_app_desc`, `backup_rules`, `data_extraction_rules`,
`network_security_config`). Five TTF fonts are bundled (`dm_sans`, `fraunces`, `pjs_bold/medium/regular`).
Details and per-file entries are in `02-files-resources.md`.

## 6. Entry points

| Entry point | Type | Where | What happens |
|---|---|---|---|
| `MainActivity` | Android Activity, LAUNCHER | `AndroidManifest.xml`; `MainActivity.java` | Decides sign-in vs signed-in shell; switches Consumer/Host/Admin tabs; handles `amperly://auth-callback` |
| `AmperlyCarAppService` | Android Auto `CarAppService`, exported | `AndroidManifest.xml`; `car/AmperlyCarAppService.java` | Creates `AmperlyCarSession`; host binds from another app |
| `AmperlyCarSession` | `Session` (Car App Library) | `car/AmperlyCarSession.java` | Records the Auto session and returns `RouteOverviewCarScreen` (the factory exists but is not used here) |
| Room database | process singleton | `AmperlyDatabase.getInstance` | Local read cache; destructive fallback |
| No workers/schedulers | — | — | **NOT VISIBLE IN CODE**: no WorkManager, JobScheduler, Service (other than car), BroadcastReceiver, or cron |
| No webhooks in app | — | — | Server-side triggers/functions only (`supabase/schema.sql`) |

## 7. Architecture style

The app is a **single-process, no-ViewModel, fragment-per-screen Android app**:

```text
MainActivity (shell: sign-in, profile/role menu, bottom tabs, per-tab back stacks)
   │  directly instantiates fragments; fragments call engines and the repository
   ▼
Engines (pure-ish Java: routing, SoC, billing, availability, booking, meter, analytics, enforcement)
   │
   ▼
AmperlyRepository  ──►  Room DAOs  ──►  SQLite cache
   │
   └──────────────►  SyncEngine / SupabaseRest / SupabaseAuth  ──►  Supabase Postgres (RLS)
   ▲
   └── AppStateStore (in-memory phone ↔ car shared trip/SoC state)
```

- **No MVVM / no ViewModel usage** is visible: `lifecycle-viewmodel` and `lifecycle-livedata` are declared
  in Gradle but no `ViewModel` class exists; some DAOs return `LiveData`, but no fragment observes it (see
  `07-quality-report.md`). Fragments own their state and call the repository on background executors.
- **No Jetpack Navigation graph** is used; navigation is fragment transactions through
  `core/nav/Navigator.java`, with tab-scoped back-stack names (`TabBackStackHost`).
- **Repository is the only DAO consumer** (plus a few direct DAO calls in `SyncEngine`/`MainActivity`;
  see `03-wiring.md` for the exact call graph).
- **Room is a cache, not the source of truth.** The repository writes Room and PostgREST; `SyncEngine`
  pulls rows since a cursor and reconciles deletes (`README.md` §1). The UI reads Room.
- **Two surfaces, one state**: phone fragments and the Android Auto screens both read `AppStateStore`
  (`core/state/AppStateStore.java`).

### Architectural drift visible in code (details in 07)

1. `README.md` says DB **v5**, but `AmperlyDatabase.java` is **version 6** with `MIGRATION_5_6`.
2. `README.md` says "no pilot seeding", but `ChargerStation.create(...)` is documented as "used by the
   seeder and tests" (`ChargerStation.java`) — no seeder file exists, so the comment is stale.
3. `app/build.gradle.kts` comment says "Without the Supabase pair the app runs fully on-device against
   Room and the local seeder" — there is no local seeder in the tree.
4. `code_search`-visible comments still say "Google map" in `MapContainerView.java` and
   `RouteProgress.java` even though Google Maps was removed (`MAPS_MIGRATION.md`).
5. `local.properties` exists locally with secret values (keys listed in `06-config-build-deploy.md`);
   it is gitignored and the keystore is present locally, so this machine can produce signed builds.

## 8. Areas and how they will be documented

| Area | Files | Doc |
|---|---|---|
| Core (common, location, map, nav, places, routing, security, state) | 32 | `02-files-core.md` |
| Data (entities, DAOs, DB, remote, repository) | 56 | `02-files-data.md`, `04-data-layer.md` |
| Engines + enums | 16 | `02-files-engines.md`, `05-flows.md` |
| UI (MainActivity, features, ui, car, payment/communication) | 53 | `02-files-ui.md` |
| Car | 14 | `02-files-car.md` |
| Resources | 115 XML (5 font binaries excluded) | `02-files-resources.md` |
| Tests + Supabase SQL | 28 | `07-quality-report.md`, `04-data-layer.md` |
| Build/config/deploy | Gradle + manifest + docs | `06-config-build-deploy.md` |
| Wiring and flows | cross-cutting | `03-wiring.md`, `05-flows.md` |
