# Amperly — pitch walkthrough

**Version 4.6.0.** The detailed product and architecture reference is [`README.md`](README.md); this
file is the short version to present from.

---

## In one line

Amperly lets a driver reserve an EV charger that already exists, plan the whole journey around it,
and pay only for kWh proven by a verified meter — on the phone and on the car display.

## The problem

- **Chargers exist; confidence does not.** Drivers juggle apps, screenshots and phone calls to find
  a port that is compatible, open and actually free.
- **"Nearest charger" is the wrong question.** Range anxiety is about the whole trip: detour,
  charge time, arrival reserve, and what happens if the first stop is broken.
- **Estimates become disputes.** A bill built from a route estimate cannot be defended. A bill built
  from a verified meter can.

## What Amperly does

| Who | What they get |
|---|---|
| **Consumer** | A garage of their cars, discovery on a real map, a corridor-aware charging plan, a reserved port, QR check-in, a metered session and an itemised receipt. |
| **Host** | A listing for an existing charger, availability from schedules and reservations, a **Dashboard** of earnings and utilisation, a **Stations** list with pause and meter evidence, and **Bookings** with the driver's QR, chat and receipt. |
| **Admin** | A **Queue** for new listings, and **Reports**: disputes with their meter evidence first, then reports from consumers and hosts as cards that open into the warn/suspend/ban decisions. |

Every range, connector-compatibility and reservation check reads **one active vehicle profile**.
Consumer and Host share one account — registering a charger is what makes the same person a host —
and an Admin account adds the platform verification desk.

## The phone — a tab for each job

The app is now organised the way people actually hold a phone: one thumb, a bottom bar, and a tab
that never loses what it was doing.

- **Each capacity gets its own tabs.** Consumer: **Discover · Trips · Bookings · Profile**. Host:
  **Dashboard · Stations · Bookings · Profile**. Admin: **Queue · Reports**.
- **A tab keeps its pages.** Switching to Discover and back to Bookings returns to the booking you
  had open, not the start of the list. Re-tapping the tab you are on closes its pages and goes back
  to the tab's first screen, like every app the judges already use.
- **A running trip survives.** The Trips tab reopens the navigation you left, and the app lands
  there after a restart when a trip is active.
- **The host desk is split by job.** **Dashboard** is the numbers — income, disputes, reservations,
  utilisation of bookable hours over 30 days — plus the session list. **Stations** is one card per
  charger with pause/reopen and meter evidence, and **Add station** opens the full form on its own
  screen. **Bookings** is one card per slot, with the driver's booking code and QR, chat and receipt.
  Station deletion sits at the bottom of Dashboard, away from the daily controls, because it cannot
  be undone.
- **The admin desk is split the same way.** **Queue** holds the pending listings and the platform
  summary. **Reports** leads with disputes, then consumer and host reports as closed cards: tap a
  card and its evidence and its three decisions — warn, suspend, ban — open **in place**, one card
  at a time. Suspension asks for its length; a ban, being permanent, confirms first.
- **The brand is real.** The launcher icon, adaptive icon and in-app mark are the Amperly logo, not
  a placeholder bolt.
- **The car display gets a map.** The car home is now a real map with the trip and the reachable
  chargers pinned, and a left sidebar carrying the trip summary and the driver-safe actions —
  provided the host supports it, with a plain list as the fallback.

**The garage is still the demo's heart.** Profile → Vehicle opens **My vehicles** as cards: name,
registration, connector, usable range, and an **In use** badge on the profile every check follows.
**Add a car** opens a blank form, tapping a card edits that car, **Use this car** switches without
opening the form, and deleting the active car promotes another one so planning never runs without a
vehicle.

## Demo script (about five minutes)

1. **Host → Stations → Add station.** Search the address, let the pin fill in, set ports, hours and
   tariff. It is **PENDING** and invisible to consumers.
2. **Admin → Queue.** Approve it; it becomes a public marker. Switch to **Reports** to show disputes
   first and a closed report card that opens in place.
3. **Consumer → Profile → Vehicle (My vehicles).** Show the card list, add a car, point at **In use**,
   switch with **Use this car**, then tap a card to show the edit form.
4. **Discover** → the map centres on the real position, shows distance, connector, power, price,
   freshness and which chargers can bill a verified session.
5. **Trips → Route planner.** Pick a destination from the Geoapify search, show the road distance and
   measured drive time, the corridor chargers, the detour/charge/arrival trade-off, the recommended
   stop and its backups, the recorded assumptions and the confidence level.
6. Switch to **Discover** and back to **Trips**: the plan is still there. Enter a **lower dashboard
   battery %**. Unreachable chargers disappear, the remaining trip is recalculated from the current
   position, and the screen shows **original → actual → revised**. Drop very low to show the **no safe
   charger** state and the alternatives.
7. **Reserve** a port → booking code and QR → check in → simulate the meter → complete → the receipt
   itemises starting/ending readings, verified kWh, energy, service fee, gateway fee and total.
8. **Host → Bookings** shows that booking as a card: open its QR, the chat, the receipt. **Dashboard**
   shows the money and the utilisation behind it.
9. **Android Auto** → the map with the trip pins, the sidebar, driver-safe navigation, and **Update
   battery**, which recalculates from the same shared trip state as the phone.

## The lines to land

1. **Meter-first billing.** No verified meter means no automatic energy charge. A station without
   one stays visible as discovery-only and can take a reservation without billing.
2. **Estimates are labelled; measurements are not invented.** Route energy, battery and arrival
   percentages say they are estimates; the receipt says "Demo meter" when the reading is simulated.
3. **The driver's battery wins.** A dashboard value overrides Amperly's estimate, removes
   unreachable chargers, adds newly reachable ones and recalculates the remaining trip.
4. **Nothing is silently hidden.** Out-of-corridor and incompatible chargers are returned with a
   reason; the plan records its assumptions; availability carries a last-updated time.
5. **Money is settled by the server.** The client can compute a bill for offline UX, but Postgres
   functions write the invoice; Row Level Security stops a modified APK from reading another
   account's rows or changing what it pays.
6. **Two surfaces, one state.** The phone and the car read the same trip and battery state without
   duplicating the plan.
7. **A tab keeps its place.** Changing tabs never cancels a plan, a navigation or a half-typed
   booking; going back returns to the page that was open, and re-tapping the tab goes home.

## Under the hood (one breath)

Android/Java, Room as the read cache, Supabase/Postgres with RLS for the source of truth, MapLibre
Native rendering OpenStreetMap data on the phone, Geoapify for address search, road routing and the
car's static map, Android Auto with `MapWithContentTemplate` for the car surface, JUnit for 150 unit
tests. No charger hardware, gateway or live traffic is claimed.

## What is real, and what is not

**Real:** corridor planning and multi-stop maths, Geoapify search/geocoding/routing, MapLibre map,
slot generation and conflict prevention, server-side booking and settlement, RLS policies, the
admin verification/dispute/enforcement flow, the card garage, per-role tab roots with per-tab back
stacks, the host dashboard/stations/bookings split, expandable admin report cards, the logo, the
painted car map, Android Auto screens, QR generation.

**Not in this build:** charger hardware/OCPP, live charger telemetry, real meter hardware, payment
capture (bookings are free holds and invoices are issued, not charged), live traffic, spoken
guidance, SMS from SOS, and Android Automotive OS. Room is not encrypted at rest. The car map is a
static map image fetched per trip or position change, not a live MapLibre GL surface — it keeps the
car display cheap and reliable.

## Judge questions, short answers

- **Why not Google Maps?** One Geoapify key covers style, search, routing and the car's static map,
  with no Google Cloud billing project; MapLibre renders the OpenStreetMap-based style on the phone.
  Attribution and plan limits are documented in [`MAPS_MIGRATION.md`](MAPS_MIGRATION.md).
- **Why Supabase?** Postgres gives us RLS and `SECURITY DEFINER` settlement functions, so the
  publishable key can ship in the APK without shipping the ability to rewrite a bill.
- **Why no OCPP?** This is the reservation, planning and trust layer over chargers that already
  exist; hardware control is deliberately out of scope for the MVP.
- **How does it make money?** A disclosed per-session service fee, gateway pass-through, and host
  analytics/verification tooling.
- **What if a charger has no meter?** It is discovery-only: reservable without automatic energy
  billing, never billed from guesswork.
- **What happens if I switch tabs mid-trip?** Nothing. Each tab owns its screen and its pages, so a
  plan or a running navigation is still there when you come back; the Trips tab even survives a
  restart while a trip is active.
- **Why is the car map a static image?** The car host hands the app a `Surface`, not an Android
  View, and MapLibre only renders into a View. A Geoapify static map painted into that surface is
  one cheap pass per trip change, with the same style and attribution as the phone.
- **Multi-car households?** The garage keeps several profiles, marks one active, and every check
  follows it.
- **What happens when the battery is lower than planned?** The driver's value becomes authoritative,
  the remaining trip is recalculated, and if nothing is safely reachable the app says so instead of
  routing past the reserve.

## Where to read more

- [`README.md`](README.md) — full product, architecture, data model and setup.
- [`SECURITY_REVIEW.md`](SECURITY_REVIEW.md) — what was hardened and what is still residual risk.
- [`supabase/README.md`](supabase/README.md) — schema, roles and the settlement contract.
