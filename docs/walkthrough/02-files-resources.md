# 02 — Files: Android resources (115 files)

Every resource file in `app/src/main/res` is listed. Line counts are in `00-manifest.md`; ids were extracted from each XML. There are no PNG/WebP assets: every background and icon is a vector or shape drawable.

---

## 1. `values/` and `values-night/` — 8 files

### `values/colors.xml` (63 lines)
Semantic roles, not raw swatches: `amp_background` warm paper, `amp_surface` white, `amp_surface_variant`, `amp_divider`, `amp_outline`; ink `amp_ink`/`amp_ink_secondary`; primary `amp_primary` deep green + dark/tint/on; energy `amp_energy` amber + tint/on; status `amp_available`/`_tint`, `amp_busy`/`_ink`/`_tint`, `amp_error`/`_tint`, `amp_info`/`_tint`; muted destructive pair `amp_delete_station_bg`/`_text`; legacy aliases `amp_primary_container`, `amp_on_secondary_container`, `amp_on_error_container`, `amp_surface_container_low/high/highest`, `amp_map_placeholder`. Layouts reference roles so night mode is a palette swap.

### `values-night/colors.xml` (57 lines)
Night palette for the same names: charcoal-green background `#151A17`, surface `#1E2521`, mint primary `#6FD0B6`, softened amber, light ink. The destructive pair is unchanged deliberately.

### `values/themes.xml` (120 lines)
`Base.Theme.Amperly` (Material3 DayNight NoActionBar) maps every color role, sets Poppins (`@font/pjs_regular`) as the single family, transparent system bars with light icons, and wires component styles: card, button, chip, toolbar, dialog, bottom sheet, snackbar, popup, shape appearances (8/12/16 dp), plus `Theme.Amperly`. `ThemeOverlay.Amperly.Dialog` uses the 16 dp top-corner sheet shape and `adjustResize` (dialogs are their own window). `ThemeOverlay.Amperly.BottomSheet` + `Widget.Amperly.BottomSheet`.

### `values-night/themes.xml` (17 lines)
Only the genuine deltas: `Theme.Amperly` turns off light status/navigation bar icons. It does **not** redefine the base style, because a night style replaces rather than merges.

### `values/dimens.xml` (24 lines)
8 dp grid: `amp_space_xs/s/m/l/xl/xxl` (4/8/16/24/32/40), screen padding 20, card radius 16, field radius 12, chip radius 50, touch target 48, section gap 24, map panel 220, details map 180, sheet handle 36×4, timeline 28, QR 232.

### `values/ids.xml` (20 lines)
Stable bottom-nav ids: `nav_discover`, `nav_route_plan`, `nav_reserve`, `nav_host_dashboard`, `nav_host_add_station`, `nav_host_bookings`, `nav_admin_queue`, `nav_admin_reports`, `nav_profile`. They exist as resources because `MainActivity.buildNavigation` adds menu items programmatically and `setSelectedItemId` needs real id resources.

### `values/strings.xml` (778 lines)
All user-facing text (~700 keys). Prefix groups: `host_` 88, `admin_` 62, `route_` 58, `vehicle_` 47, `session_` 40, `nav_` 31, `safety_` 28, `auth_` 26, `reserve_` 25, `account_` 23, `discovery_` 22, `receipt_` 21, `report_` 16, `error_` 16, `soc_` 14, `details_` 14, `dispute_` 12, `action_` 12, `map_` 11, `chat_` 10, `sync_` 9, `label_` 9, `location_` 8, `timeline_` 7, `stop_` 6, `qr_` 6, `filter_` 6, `directions_` 6, `booking_` 6, `analytics_` 6, `unit_` 5, `reservation_` 5, `unsaved_` 4, `pref_` 4, `pending_` 4, `station_` 3, `notifications_` 3, `line_` 3, `notification_` 2, `meter_` 2, `dialog_` 2, `car_` 2, `cancel_` 2, `empty_`/`contact_`/`brand_`/`app_` 1 each. Key contracts: `reserve_slot_taken`, `reserve_slot_in_past`, `reserve_slot_too_long`, `reserve_server_required`, `session_server_required`, `session_invalid_reading`, `auth_*`, `error_*`, `sync_failed`, `map_setup_required`, `map_attribution`, `car_sos_notice`. No user-facing text is hard-coded in Java except car template copy and a few labels in `CarBridge`/`CarMap` (see Q12).

### `values/styles.xml` (487 lines)
Text appearances: Display, Title, TitleSmall, Body, BodySmall, BodyStrong, Label, LabelStrong, Metric, MetricSmall, Number, Button, NavLabel(.Active), Wordmark, SectionTitle. Widgets: Button (base/Tonal/Outlined/Code/Text/Energy/Danger/DeleteStation), Card (base/Filled/Plain/Map), Chip, Badge (Success/Info/Neutral), Notice (base/Info/Warning/Error), TextInput, Divider, SheetHandle, RowLabel, RowValue, StickyActionBar, StepNumber, ScreenBody, SectionTitle, NavIndicator, Toolbar, RoleChip, Snackbar, SnackbarButton, PopupWindow, PopupMenu. These are the only place radii/typography/colour are applied.

---

## 2. `color/` — 4 files

| File | Type | Purpose |
|---|---|---|
| `amp_chip_bg.xml` (5) | selector | chip background by selected/enabled state |
| `amp_chip_text.xml` (5) | selector | chip label colour by state |
| `amp_field_stroke.xml` (5) | selector | text-field stroke focused/error/default |
| `nav_item_tint.xml` (5) | selector | bottom-nav icon/label tint selected/unselected |

---

## 3. `drawable/` — 48 files

### Backgrounds / shapes (26)
`bg_avatar_lime` (avatar circle), `bg_badge_info`, `bg_badge_neutral`, `bg_badge_success`, `bg_badge_warning` (status pills), `bg_bottom_nav` (layer-list top hairline + surface), `bg_brand_mark` (rounded brand tile), `bg_dashed_divider`, `bg_dot_lime` (unread dot), `bg_notice_error`, `bg_notice_info`, `bg_notice_neutral`, `bg_notice_warning` (inline notices), `bg_notification_card`, `bg_notification_card_unread`, `bg_profile_chip`, `bg_sheet_handle`, `bg_sheet_top` (top-rounded sheet), `bg_station_row_selected`, `bg_step_number` (numbered circle), `bg_sticky_bar` (layer-list bottom action bar), `bg_timeline_slot` (availability cell).

### Icons (22 vectors)
Navigation/actions: `ic_account`, `ic_add`, `ic_battery`, `ic_brand_mark`, `ic_check`, `ic_chevron`, `ic_chevron_down`, `ic_dashboard`, `ic_discover`, `ic_flag`, `ic_notifications`, `ic_pencil`, `ic_phone`, `ic_pin`, `ic_queue`, `ic_reserve`, `ic_route`, `ic_session`, `ic_vehicle`, `ic_warning`.
Connectors: `ic_connector_type2`, `ic_connector_ccs2`, `ic_connector_chademo`.
Launcher layers: `ic_launcher_background`, `ic_launcher_foreground`, `ic_launcher_monochrome`.

The connector icons are selected by `ConnectorType`/`Formatters` and appear in station rows, details and the car detail line.

---

## 4. `layout/` — 45 files

### Shell (1)
`activity_main.xml` (91): `main` root, `appBarLayout`, `topToolbar`, `brandLockup`, `appBarDivider`, `fragment_container` (weight 1), `bottomNavigationView` (labeled, 24 dp icons, custom indicator/tint). The toolbar title is disabled in code; the brand lock-up is the visual title.

### Dialogs (5)
| Layout | Ids | Used by |
|---|---|---|
| `dialog_edit_name.xml` (49) | `editNameField`, `editNameInput` | Account rename |
| `dialog_input_number.xml` (47) | `numberField`, `numberInput` | battery update / numeric prompts |
| `dialog_meter_evidence.xml` (71) | `meterEvidenceHeader`, `meterStartEdit`, `meterEndEdit`, `meterNoteEdit` | `MeterEvidenceDialog` |
| `dialog_place_search.xml` (25) | `placeSearchEdit` | `PlaceSearchDialog` |
| `dialog_report.xml` (51) | `reportTypeField`, `reportTypeDropdown`, `reportDetailsField`, `reportDetailsEdit` | `ReportDialog` |

### Fragments (20)
`fragment_account` (220) — profile, avatar, name/email/authority, edit, role chips, sync/sign-out.
`fragment_active_session` (256) — state/info, live kWh/time/cost, start/end meter, capture/simulate, stop-and-bill.
`fragment_admin_dashboard` (142) — platform analytics, pending queue list, consumer reports, disputes.
`fragment_booking_qr` (99) — QR image, code, station/slot, hint, go-to-session.
`fragment_charger_details` (340) — name/address/availability/freshness/total/verification, meter gating, timeline, map, reserve.
`fragment_charger_discovery` (378) — CoordinatorLayout, map, battery hero/progress, vehicle switcher, context, station list.
`fragment_host_bookings` (48) — list + empty state.
`fragment_host_chat` (154) — masked disclaimer, thread chips, title/expiry, messages, empty, quick questions.
`fragment_host_dashboard` (158) — host name, income/disputes/reservations/utilization metrics, analytics container, empty.
`fragment_host_stations` (91) — station list, empty, add.
`fragment_in_app_navigation` (77) — map, next turn, instruction, remaining, ETA, status, update battery, stop.
`fragment_notifications` (44) — list + empty.
`fragment_receipt` (113) — paid block, title/station/pending, billing container, total.
`fragment_register_station` (450) — name/address/lat/lng, map, GPS/place buttons, tariff/fees, connectors/power/ports, verification, access, hours.
`fragment_reservation` (305) — station chooser, vehicle/port/slot dropdowns, price, reserve, reservation list.
`fragment_route_planner` (570) — origin/details/map button, destination + resolved text, vehicle, preferences, exclusions, summary, stops, start.
`fragment_safety_sos` (149) — notice, SOS button/status, contacts list, name/phone/add.
`fragment_sign_in` (193) — brand heading/tagline, name/email/password fields, submit, mode switch.
`fragment_vehicle_form` (414) — make/model/variant/year/plate/capacity/connector/AC/DC/efficiency/health/min-max SoC.
`fragment_vehicle_profile` (92) — vehicle list, empty, add.

### Items (18)
`item_admin_station` (70), `item_billing_line` (26), `item_chat_message` (44), `item_contact` (52), `item_dispute` (143), `item_dropdown` (19), `item_host_booking` (95), `item_notification` (50), `item_place_suggestion` (34), `item_port` (50), `item_report` (138), `item_reservation` (130), `item_role_chip` (13), `item_route_stop` (87), `item_session` (89), `item_station` (170), `item_station_card` (93), `item_vehicle_card` (98). Each maps 1:1 to the adapter of the same subject in `02-files-ui.md`.

### View (1)
`view_profile_button.xml` (56) — `profileBadge`, `profileBadgeText` (initials), `profileNameText`, `profileRoleText`; inflated as the toolbar action view.

---

## 5. Menus — 2 files

`menu/main_menu.xml` (22): `action_notifications` (bell, always) and `action_profile` (always; replaced by the badge action view). `menu/profile_menu.xml` (22): `profile_action_account`, `profile_action_vehicle`, `profile_action_safety`, `profile_action_sign_out` (sign-out hidden unless `SupabaseAuth.isSignedIn()`).

---

## 6. Mipmaps — 4 files

`mipmap-anydpi-v26/ic_launcher.xml` (11) and `ic_launcher_round.xml` (7): adaptive icon with background/foreground/monochrome. `mipmap-anydpi/ic_launcher.xml` (18) and `ic_launcher_round.xml` (13): legacy layer-list fallbacks. All reference the vector layers above; no PNG mipmaps exist.

---

## 7. `xml/` — 4 files

| File | Purpose |
|---|---|
| `automotive_app_desc.xml` (4) | `<uses name="template"/>` — declares the Car App Library template app |
| `network_security_config.xml` (16) | cleartext **denied** for every domain, system trust anchors only; manifest also sets `usesCleartextTraffic="false"` for API 24–27 |
| `backup_rules.xml` (15) | Android ≤11 full-backup exclusions: root/file/database/sharedpref/external — session tokens and Room are never backed up |
| `data_extraction_rules.xml` (25) | Android 12+ cloud-backup **and** device-transfer exclusions for the same domains |

`allowBackup` is false in the manifest; these files are the second line of defence.

---

## 8. Resource gaps / drift

- `strings.xml` is ~700 keys for 20 screens, with near-duplicate keys across host/admin/route areas; no unused-key check exists.
- Text is hard-coded in car templates and a few builders (`CarBridge`/`RouteOverviewCarScreen`/`NavigationCarScreen` load some strings from resources but not all), so the car is not fully localisable (Q12).
- `MapContainerView`/`RouteProgress` comments refer to Google; the actual map stack is MapLibre + Geoapify (Q5).
- Font files (`res/font/pjs_*.ttf`) are binary and therefore not in the manifest; the theme references `@font/pjs_regular`.
