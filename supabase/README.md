# Amperly — Supabase setup

This folder is the **entire** database side of Amperly. There is no other Supabase
code, config or hidden SQL in this repository.

| File | What it is |
|---|---|
| `schema.sql` | All 23 tables, Row Level Security, policies, helper functions, indexes, grants. **This is the file you were looking for.** |
| `pilot_seed.sql` | Optional demo data (6 stations, 12 ports, 84 schedules, and the records the demo script needs). |
| `link_pilot_users.sql` | Connects the seeded users to real Supabase Auth accounts. |

---

## Run order

Do these in order. Each step is safe to re-run.

### 1. Create the tables

Supabase Dashboard → **SQL Editor** → **New query** → paste the whole of
`schema.sql` → **Run**.

You should end with 23 tables in the `public` schema, all with a red
"RLS enabled" marker in Table Editor.

### 2. (Optional) Add the pilot data

New query → paste `pilot_seed.sql` → **Run**.

Verify:

```sql
select (select count(*) from public.charger_stations)       as stations,   -- 6
       (select count(*) from public.charger_ports)          as ports,      -- 12
       (select count(*) from public.availability_schedules) as schedules,  -- 84
       (select count(*) from public.users)                  as users;      -- 4
```

### 3. Where the URL and publishable key go

**Get them from:** Dashboard → **Project Settings** → **API Keys**
(also shown on the project home screen as "Connect").

Copy two values:

- **Project URL** — looks like `https://abcdefghijklmnop.supabase.co`
- **Publishable key** — looks like `sb_publishable_xxxxxxxxxxxx`
  (This is the renamed `anon` key. If your project still shows the legacy keys,
  the `anon` key works in exactly the same place.)

**Paste them into `local.properties`** in the project root — the same file that
already holds `sdk.dir` and `MAPS_API_KEY`:

```properties
sdk.dir=C\:\\Users\\<you>\\AppData\\Local\\Android\\Sdk
MAPS_API_KEY=your_google_maps_key

SUPABASE_URL=https://abcdefghijklmnop.supabase.co
SUPABASE_PUBLISHABLE_KEY=sb_publishable_xxxxxxxxxxxx
```

`local.properties` is in `.gitignore`, so the key is never committed. `app/build.gradle.kts`
reads both values (falling back to the `SUPABASE_URL` / `SUPABASE_PUBLISHABLE_KEY`
environment variables) and exposes them as `BuildConfig.SUPABASE_URL` and
`BuildConfig.SUPABASE_PUBLISHABLE_KEY`.

**If these are absent, the app runs exactly as it does today** — on-device Room
plus the local seeder, no networking. Nothing breaks.

> ### ⚠️ The publishable key is only safe because of RLS
> A publishable key ships inside your APK and is designed to be public. That is
> only true because `schema.sql` turns on Row Level Security for every table and
> writes policies for it. It is not a secret, and you should not treat it as
> one — but if you ever disable RLS on a table, anyone who unzips your APK can
> read and write that table.
>
> **Never** put a `sb_secret_...` key (the old `service_role` key) in
> `local.properties` or anywhere in the app. It bypasses RLS completely.

### 4. Create the Auth accounts and link them

The seeded users only become *real* users once they have an Auth account.

Dashboard → **Authentication** → **Users** → **Add user** → **Create new user**.
Create one per pilot user, using the same email as the seed, with a password you
choose, and tick **Auto Confirm User**:

| Email | Application role |
|---|---|
| `host@abccollege.edu` | Host — ABC College |
| `aarav@abccollege.edu` | Consumer — the student |
| `president@greenpark.org` | Host — GreenPark |
| `admin@amperly.app` | Platform administrator |

Then run `link_pilot_users.sql`. It matches on email, so you do not need to copy
any UUIDs by hand.

---

## What each role can do

The policies in `schema.sql` implement this. Row Level Security is enforced by
Postgres, not by the app, so a modified APK cannot get around it.

| | Anonymous | Consumer | Host | Admin |
|---|---|---|---|---|
| Browse approved chargers, ports, schedules | ✅ | ✅ | ✅ | ✅ |
| See PENDING / paused stations | ❌ | ❌ | on their own stations | ✅ |
| Own vehicle, route plans, battery updates | ❌ | ✅ | ✅ | ✅ |
| Own reservations, sessions, invoices | ❌ | ✅ | — | ✅ |
| Reservations and sessions for their stations | ❌ | — | ✅ | ✅ |
| Write meter readings | ❌ | their own session's reading | ✅ | ✅ |
| Capture, refund, cancel, settle a bill | ❌ | via a function | via a function | ✅ |
| Issue invoices, refunds, disputes resolution | ❌ | ❌ | ❌ | ✅ |
| Chat | ❌ | participants only | participants only | ✅ |
| Change a user's role or block state | ❌ | ❌ | ❌ | ✅ |

Two deliberate hard rules worth knowing about, because they are the ones an
attacker would try first:

- **A consumer cannot decide what they are charged.** They may add a meter
  reading for their own session, but the reading the bill is calculated from —
  and the amount itself — are written by `finalize_charging_session()` on the
  server. `payments` and `invoices` have no client write policy at all, and the
  billing columns of `charging_sessions` are pinned by a trigger.
- **A user cannot promote themselves.** Roles are a column on `users`, and the
  obvious attack is to `PATCH` your own row and set `role = 'ADMIN'`. The
  `prevent_privilege_escalation` trigger rejects any role, block-state or
  verification-status change from a non-admin, which is something a policy alone
  cannot express.

---

## Money is settled by functions, not by the client

The app computes a bill locally so that it works offline, but the client is no
longer allowed to *store* one. The billing transitions go through
`SECURITY DEFINER` functions, called as `POST /rest/v1/rpc/<name>`:

| Function | Who may call it | What it does |
|---|---|---|
| `authorize_payment` | the consumer booking | Creates the authorization (a hold, not a charge) |
| `finalize_charging_session` | that reservation's consumer or host | Recomputed from the meter readings; writes the session, the receipt and the capture, closes the reservation, frees the port |
| `cancel_reservation` | that reservation's consumer or host | Applies the published late-cancellation policy server-side and releases the hold |
| `decide_station_approval` | admin | Approves or rejects a listing and notifies the host |
| `resolve_dispute_refund` | admin | Refunds the invoice's energy charge, refunds the payment, resolves the dispute |
| `freeze_dispute_payout` | admin | Holds the host's payout |
| `apply_host_enforcement` | admin | Records the enforcement action and pauses the station when the policy calls for it |

Each one checks who is calling before it writes, and the app queues the call in
the same outbox it uses for row edits, so an offline device still settles in
order once it reconnects.

Three things to keep in mind:

- **Run `schema.sql` as the table owner** — the Supabase SQL editor does this.
  The functions are `SECURITY DEFINER`, and the guard triggers treat a session
  whose `current_user` is neither `anon` nor `authenticated` as trusted. If the
  functions ended up owned by some other role, RLS would apply to their writes
  too and settlements would fail.
- **A stale write is refused, not lost.** A queued row from a build that still
  wrote payments or invoices directly is rejected by RLS and stays in the outbox;
  clearing it (sign out, or `SyncEngine.reset`) drops those entries.
- **The server's figure is the one that counts.** After a settlement, pull so the
  locally computed amounts are replaced by the server's.

---

## How the schema relates to the app

Column names here are **quoted camelCase and identical to the Java field names**
in `app/src/main/java/com/amperly/app/data/local/entity/`. None of the Room
entities use `@ColumnInfo`, so the names already matched on the device side too.

That is deliberate: it means a PostgREST response deserialises straight into the
existing entity classes with no DTO or mapping layer at all:

```
PostgREST JSON key  ==  Java field name  ==  Room column
```

The cost is quoted identifiers in SQL. Two columns exist only on the server and
are ignored by the app's JSON parser:

- **`users."authUserId"`** — links an application user to an Auth account.
- **`"serverUpdatedAt"`** — stamped by a trigger on every UPDATE, and what makes
  incremental sync possible. Do not remove it, and do not edit it from the app.

---

## Troubleshooting

**"new row violates row-level security policy"** — the signed-in user is not
linked, so `current_app_user_id()` returned null. Run step 4 and confirm the
`linked` column came back `true`.

**Queries return an empty list instead of an error** — that is RLS working
correctly: you are seeing zero rows because no policy grants you any. Same fix
as above.

**401 / "No API key found in request"** — `SUPABASE_PUBLISHABLE_KEY` is empty or
still the placeholder. Check `local.properties` and rebuild; `BuildConfig` values
are baked in at compile time.

**A new column or table is not visible to the API** — PostgREST caches the
schema. Run `notify pgrst, 'reload schema';`, or wait a few seconds and retry.

**Consumer discovery shows nothing** — discovery deliberately exposes only
stations with `"approvalStatus" = 'APPROVED'` and `"isPaused" = false`. The
seeded `st_office_pending` is meant to be invisible until an admin approves it.

**Testing policies by hand** — RLS applies to the API roles, not to you in the
SQL editor, so a query that works in the editor may still fail from the app. To
check what a signed-in user actually sees, impersonate them:

```sql
set local role authenticated;
set local request.jwt.claims = '{"sub":"<auth-user-uuid>"}';
select * from public.reservations;
reset role;
```
