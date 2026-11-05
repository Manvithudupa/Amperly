# Amperly — codebase walkthrough

A complete, static handover of the Amperly Android app as it exists on 2026-11-04. Start here, then read in the order below. Everything is derived from the working tree; where the code and the README disagree, the code is reported and the drift is listed in `07-quality-report.md`.

## Read in this order

| # | File | What it answers |
|---|---|---|
| 00 | [`00-manifest.md`](00-manifest.md) | Every text file in the repo, with line counts and a tick when documented. 317 entries / 43,042 lines. |
| 01 | [`01-project-map.md`](01-project-map.md) | Purpose, stack, versions, annotated tree, entry points, architecture in one page. |
| 02 | [`02-files-core.md`](02-files-core.md) | `core/`: constants, formatting, geo, map, navigation, places, routing, security, state (32 files). |
| 02 | [`02-files-data.md`](02-files-data.md) | Room v6, all 23 entities/DAOs, Supabase client/auth/sync, the 1,935-line repository (56 files). |
| 02 | [`02-files-engines.md`](02-files-engines.md) | Availability, booking, billing, meter, planner, SoC, enforcement, analytics, payment, chat (16 files). |
| 02 | [`02-files-ui.md`](02-files-ui.md) | `MainActivity`, 20 fragments, 13 adapters, 4 dialogs, `Ux` (53 files). |
| 02 | [`02-files-car.md`](02-files-car.md) | Android Auto service/session/bridge/map/screens (14 files). |
| 02 | [`02-files-resources.md`](02-files-resources.md) | Every XML resource: themes, colors, styles, strings, 45 layouts, 48 drawables (115 files). |
| 03 | [`03-wiring.md`](03-wiring.md) | The call graph: shell → fragments → repository → Room/Supabase; car; map/routing; sync. |
| 04 | [`04-data-layer.md`](04-data-layer.md) | The 23-table schema, RLS, RPCs, triggers, money model, sync semantics, retention. |
| 05 | [`05-flows.md`](05-flows.md) | Sign-in, discovery/battery, planning, booking, session/billing, host/admin, disputes, chat/SOS, car, offline. |
| 06 | [`06-config-build-deploy.md`](06-config-build-deploy.md) | Gradle, SDK levels, BuildConfig keys, manifest, Supabase/Geoapify setup, build/test/release. |
| 07 | [`07-quality-report.md`](07-quality-report.md) | 22 findings (severity, evidence), strengths, test inventory, security/performance notes, drift register. |
| 08 | [`08-completeness-check.md`](08-completeness-check.md) | What was read line-by-line vs structurally, what is [INFERRED], open questions, next reads. |
| 09 | [`09-symbol-index.md`](09-symbol-index.md) | Generated `line: signature` index for all 157 Java files — resolves names to exact lines. |

## The system in one page

- **Client**: single-module Android app, Java 17, minSdk 24 / target 35, classic Views + Material 3, no Compose, no ViewModel, no DI, no Navigation component.
- **Shell**: `MainActivity` owns a toolbar, one fragment container and a programmatic bottom nav per role (Consumer / Host / Admin). Tabs are **hidden, not replaced**, and pages opened on a tab are filed under it, so a plan/trip/form survives tab switches.
- **Backend**: Supabase Postgres + GoTrue. Room (v6, 23 entities) is a **cache**; PostgREST/RLS is the authority. No seed data; a new install signs in and pulls.
- **Money & slots**: server functions (`create_reservation`, `finalize_charging_session`, `cancel_reservation`, `resolve_dispute_refund`, `freeze_dispute_payout`, `apply_host_enforcement`, `decide_station_approval`). No payment gateway is connected; no money moves.
- **Maps/routing**: MapLibre + Geoapify on the phone; a Geoapify **static map** painted into the car Surface. No Google Maps/Navigation SDK, despite comments.
- **Car**: Android Car App Library, navigation category; glanceable snapshot only — battery correction, reserve-next-slot, navigation, lists. No typing, payment, meter or host control.
- **Engines**: pure Java for availability, reservation, billing, meter simulation, route planning, SoC correction, enforcement, analytics, payments, chat. They compute the same rules the server enforces, so the UI can explain them offline.

## The five things to understand first

1. **The server is the product; the app is a cache and a view.** Room never decides a slot, a price or a permission. Every write that matters goes through a Postgres function; a refused write is reported, not queued.
2. **`MainActivity` is the navigation system.** Tab tags, hidden tab fragments, saved back stacks and per-role menus are all in one 1,260-line class. If a screen disappears or a tab resets, look here first.
3. **`AmperlyRepository` is the second monolith (1,935 lines).** All reads/writes, RPC calls, sync and session/profile bookkeeping pass through it, on one background thread. Screen behaviour is usually a thin wrapper around a repository method.
4. **The numbers are policy, and they are spread across engines.** 45 km/h planner speed (60 in the legacy `TripTimeEngine`), 15 % reserve, 0.8 charging efficiency, ₹18/kWh fallback, ₹5/₹4 fees, ₹20 late fee, ₹500 fine, 12-hour hold, 60-minute free cancellation, 12-hour SoC cache. Changing a product rule means changing the engine *and* the SQL function.
5. **There is no hardware and no payments.** The meter is manual or `MeterSimulator`; `authorize_payment` is not called; the car has no GPS. Any assumption otherwise will misread the codebase.

## How this was produced, and its limits

Static audit of the working tree; no app was run, no tests were executed, no Supabase project was queried. `08-completeness-check.md` lists exactly which files were read line-by-line, which were structurally inspected, and the nine inferences that remain. Reports 02–05 cite files and symbols; `09-symbol-index.md` supplies the line numbers. No source file was modified — only this folder was written.
