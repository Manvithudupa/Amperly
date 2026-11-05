# 08 — Completeness check

This report is deliberately conservative: it distinguishes **read line-by-line** from **structurally inspected** and marks every inference. No claim in reports 01–07 should be read as “verified at runtime” — this was a static audit; no build, test, emulator or database was executed for it.

---

## 1. Manifest reconciliation

`00-manifest.md` was regenerated from the working tree on 2026-11-04:

- **317 entries**, **43,042 text lines**.
- Excluded by rule: `.git/`, `build/`, `.gradle/`, `.idea` (except its `.gitignore` note), `local.properties`, `keystore/amperly-release.jks`, font binaries, PNG/WebP images, Gradle caches.
- Duplicates found and removed: `app/build.gradle.kts` (listed by two find passes) and `.gitignore` (root + docs section). Self-referential `docs/walkthrough/` entries were removed from the manifest.
- The earlier 323-file count included 5 TTF font binaries and a duplicate; 317 is the correct text-file count.
- Every entry is ticked. “Ticked” means the file is named and described in `02-files-*.md` or in 03–07; it does not mean every line was read (see §2).

Breakdown: 157 Java files (32 core, 56 data, 16 domain/engines/payment/communication, 53 UI/car), 115 resource XML, 25 test files, 3 SQL files, 10 root/build files, 5 app-module config files, and 2 unique documentation/metadata files (`.idea/.gitignore`, `.freebuff/project-id`; the root and app `.gitignore` are counted above).

`09-symbol-index.md` was generated from the same tree: 157 Java sections, each with `line: signature` for class/method declarations. It is the line-number authority for names cited in 02–05. Multi-line signatures show their first line; constructors are included; lambdas and anonymous overrides may be absent.

---

## 2. Coverage by area

| Area | Files | Read line-by-line | Structural / partial | Notes |
|---|---|---|---|---|
| `core/` | 32 | 32 | 0 | all read in full |
| `data/local` + `data/remote` + repository | 56 | 56 | 0 | all entities, DAOs, database, remote, repository read in full |
| `domain/enums` | 5 | 5 | 0 | trivial enums |
| `engine/` (9) + `payment` + `communication` | 11 | 9 | 2 | `PaymentManager`, `ChatManager` bodies not read end-to-end; described from declarations, call sites and tests |
| `MainActivity` | 1 | lines 1–1090 | lines 1091–1260 | tail contains tab show/replace helpers; names inferred from references/Javadoc |
| `feature/` fragments | 20 | 0 | 20 | method inventories + layouts + call sites; behaviour at interaction level is [INFERRED] where not directly traceable |
| `ui/` (Ux, 13 adapters, 4 dialogs) | 18 | 0 | 18 | declarations + item layouts; adapters are mechanical binds |
| `car/` | 14 | 7 | 7 | service, session, bridge, factory, map, overview, navigation read fully; other screens inventoried |
| `res/` | 115 | ~15 | ~100 | every XML root/id inventoried; colors, dimens, ids, themes, night themes, menus, xml configs read; strings/styles/layouts/drawables inspected structurally |
| tests | 25 | 0 | 25 | class/method names and assertions' intent extracted; bodies not read line-by-line |
| `supabase/schema.sql` | 1 | tables 61–519 | 520–2447 | table definitions read; function/RLS/trigger **bodies** indexed, not read line-by-line |
| `supabase/security_hardening.sql` | 1 | 0 | 1 | described from its README contract; SQL body not read |
| `supabase/README.md` | 1 | full | — | |
| root docs/build | 15 | 15 | — | README, PITCH, SECURITY_REVIEW, MAPS_MIGRATION, Gradle files read in full |

**Every file in the tree is named and given a purpose somewhere in this folder.** The distinction above is about proof depth, not coverage of the file list.

---

## 3. Partial and skipped work (explicit)

1. `MainActivity.java` lines 1091–1260: `loadRoot`, `showTab`, `replaceTabRoot` and the remaining tab helpers were not read. Their behaviour is inferred from call sites and comments.
2. All 20 fragments under `feature/`: line-by-line bodies were not read. Descriptions rely on the layout id inventory, method signatures, string resources, and repository call sites. Specific interactions (e.g. exact QR encoder, SOS dispatch, timeline taps) are marked [INFERRED].
3. `ui/Ux.java`, 13 adapters, 4 dialogs: declarations/layouts only; no line-by-line body read.
4. `PaymentManager.java`, `ChatManager.java`: declarations/tests only; lifecycle details may be incomplete.
5. Seven car screens (`ChargerListCarScreen`, `ChargerDetailsCarScreen`, `SoCUpdateCarScreen`, `ReservationStatusCarScreen`, `TripHistoryCarScreen`, `VehicleCarScreen`, `CarSettingsScreen`): templates and copy not read line-by-line.
6. `values/strings.xml` (778 lines) and `values/styles.xml` (487): keys, counts and representative messages read; not every value.
7. 45 layouts, 48 drawables: every root element and `android:id` extracted; not every attribute/style.
8. 24 JVM test bodies and the instrumented test: method names/intent only; no assertion-by-assertion review.
9. `supabase/schema.sql` lines 520–2447: function bodies, all policies and trigger bodies were not read line-by-line; names, line numbers and contracts come from the object index, table section and `supabase/README.md`.
10. `supabase/security_hardening.sql`: not read line-by-line.
11. Binary assets (fonts, launcher PNGs if any), `local.properties` values, keystore contents: intentionally excluded.
12. No runtime verification: `./gradlew test`, lint, install, DHU, Supabase SQL and RLS impersonation were **not** run. Quality findings are static.

---

## 4. `[INFERRED]` register and questions to remove each

| # | Inference | Where | Question that would settle it |
|---|---|---|---|
| I1 | The seven unread car screens use the templates/rows described | `02-files-car.md` | Can you confirm each screen's `onGetTemplate` template type and row/actions? |
| I2 | `BookingQrFragment` generates the QR locally (encoder library not visible in the header) | `02-files-ui.md` | Which QR library/API produces `qrImageView`'s bitmap? |
| I3 | `SafetySOSFragment` records/shares but does not call emergency services | `02-files-ui.md`, `05-flows.md` | Is any `Intent.ACTION_CALL`/SMS/emergency API invoked? |
| I4 | Exact fragment interactions (timeline taps, chooser flows, dialog results) | `02-files-ui.md` | Which fragments should be read line-by-line to replace the interaction summaries? |
| I5 | `PaymentManager` lifecycle beyond the tested transitions | `02-files-engines.md` | Is `authorize_payment` ever called from a build variant or feature flag? |
| I6 | `ChatManager` expiry/block semantics | `02-files-engines.md` | What exact duration and UI enforcement applies to `expiresAtMs`? |
| I7 | MainActivity tail helpers (`loadRoot`, `showTab`, `replaceTabRoot`) | `02-files-ui.md`, `03-wiring.md` | Should the last 170 lines be read to confirm show/hide vs replace semantics? |
| I8 | Resource style intent (which widget uses which style) | `02-files-resources.md` | Which screens were visually reviewed against the style definitions? |
| I9 | SQL function bodies beyond the README contract | `04-data-layer.md` | Should `schema.sql` 520–2447 and `security_hardening.sql` be read line-by-line next? |

No other statement in 02–07 is marked [INFERRED]; those statements are traceable to a file/symbol in the manifest or symbol index. If a claim is not in this table and not cited, treat it as a documentation gap to raise.

---

## 5. Consistency checks performed

- Manifest paths and line counts regenerated from the tree; duplicates removed; totals recomputed (317 / 43,042).
- Symbol index generated from all 157 Java files; every class named in 02–05 appears there.
- Cross-checked entity count (23), DAO count (23), table count (23), car file count (14), fragment count (20), adapter count (13), test file count (25) against the manifest.
- Cross-checked README claims against code and recorded drift in Q3, Q4, Q5, Q7, Q8, Q9.
- Checked that no source file was modified: only `docs/walkthrough/` was written; `PITCH.md` was already untracked before the audit.
- Checked the required file set: `00`–`08`, area files (core, data, engines, UI, car, resources), plus `09-symbol-index.md`; `README.md` is the index.

---

## 6. Recommended next reads (in order)

1. `MainActivity` 1091–1260 — confirms tab retention, the riskiest shell behaviour.
2. The four money/admin fragments (`ReservationFragment`, `ActiveSessionFragment`, `AdminDashboardFragment`, `ReceiptFragment`) — confirms every RPC argument and refusal path.
3. `schema.sql` 520–2447 + `security_hardening.sql` — confirms RLS/RPC bodies behind every security claim.
4. `SupabaseAuth` refresh paths and `SyncEngine` end-to-end with a test project — the two least-tested high-risk areas.
5. The seven car screens — completes the projection surface.

These are explicitly **not** claimed as done. Everything else in the requested scope is documented to the depth stated in §2.
