# Amperly — Supabase setup

This folder is the **entire** database side of Amperly. There is no other Supabase
code, config or hidden SQL in this repository.

| File | What it is |
|---|---|
| `schema.sql` | All 23 tables, Row Level Security, policies, helper functions, indexes, grants, the settlement functions money is written through, the `auth.users` trigger that gives every account its profile, and the backfill that repairs accounts created before it. **This is the file you were looking for.** |
| `security_hardening.sql` | Locks the columns an attacker would use to skip review: listing self-approval, forged reputation, dispute self-resolution and self-marked payments. **Run this on any project created before it existed.** |
| `create_admin.sql` | Creates the platform administrator (`admin@amperly.app`) with a bcrypt password and the ADMIN role. |

---

## Run order

Do these in order. Each step is safe to re-run.

### 1. Create the tables

Supabase Dashboard → **SQL Editor** → **New query** → paste the whole of
`schema.sql` → **Run**.

You should end with 23 tables in the `public` schema, all with a red
"RLS enabled" marker in Table Editor.

The last statement in the file prints every Auth account next to the application
profile it resolves to. Every row must show an `app_user_id`: a blank one is the
single cause of an app that signs in and then shows nothing at all.

On a fresh project there is **no data to import**: the app ships no seed rows and
fills the tables as accounts use it. `public.vehicles` is ready for several
profiles per account (`"isActive"` marks the one the app plans against); the
`alter table` after the table definition adds that column to an older project too.

### 1b. Close the listing-review holes (existing projects only)

If the project already had `schema.sql` applied before `security_hardening.sql`
existed, run `security_hardening.sql` now. It is idempotent and only replaces
trigger functions.

### 1c. Create the administrator

Edit `create_admin.sql` first and set `v_password` to a password of at least 12
characters — the file refuses to run with the placeholder in place, and a real
password must never be committed. Then paste the file into a new query and
**Run**. Email defaults to `admin@amperly.app`.

After the first sign-in you can change the password from Authentication → Users
in the dashboard, but then update your own copy of that password: the SQL file
only creates the account, it does not store it for you.

### 2. Add your chargers

There is no seed data. Sign in to the app, switch to the **Host** capacity and add a charger from
**Stations**; an administrator then approves it from the verification queue. Nothing is inserted
into the database by this repository.

### 3. Where the URL and publishable key go

**Get them from:** Dashboard → **Project Settings** → **API Keys**
(also shown on the project home screen as "Connect").

Copy two values:

- **Project URL** — looks like `https://abcdefghijklmnop.supabase.co`
- **Publishable key** — looks like `sb_publishable_xxxxxxxxxxxx`
  (This is the renamed `anon` key. If your project still shows the legacy keys,
  the `anon` key works in exactly the same place.)

**Paste them into `local.properties`** in the project root — the same file that
already holds `sdk.dir` and `GEOAPIFY_API_KEY`:

```properties
sdk.dir=C\:\\Users\\<you>\\AppData\\Local\\Android\\Sdk
GEOAPIFY_API_KEY=your_geoapify_key

SUPABASE_URL=https://abcdefghijklmnop.supabase.co
SUPABASE_PUBLISHABLE_KEY=sb_publishable_xxxxxxxxxxxx
```

`local.properties` is in `.gitignore`, so the key is never committed. `app/build.gradle.kts`
reads both values (falling back to the `SUPABASE_URL` / `SUPABASE_PUBLISHABLE_KEY`
environment variables) and exposes them as `BuildConfig.SUPABASE_URL` and
`BuildConfig.SUPABASE_PUBLISHABLE_KEY`.

**If these are absent, the app cannot sign in**: the server is the only source of truth, so there
is no local demo path to fall back to.

> ### ⚠️ The publishable key is only safe because of RLS
> A publishable key ships inside your APK and is designed to be public. That is
> only true because `schema.sql` turns on Row Level Security for every table and
> writes policies for it. It is not a secret, and you should not treat it as
> one — but if you ever disable RLS on a table, anyone who unzips your APK can
> read and write that table.
>
> **Never** put a `sb_secret_...` key (the old `service_role` key) in
> `local.properties` or anywhere in the app. It bypasses RLS completely.

### 4. Create the Auth accounts

`schema.sql` installs a trigger on `auth.users`, so an Auth account and its
`public.users` profile are created together and cannot drift apart. Creating the
Auth account is now the only step needed — no UUIDs are copied by hand and there
is no separate linking run.

Dashboard → **Authentication** → **Users** → **Add user** → **Create new user**.
Create one per person who will use the app, with an email and a password you
choose, and tick **Auto Confirm User**:

| Email | Application role |
|---|---|
| `admin@amperly.app` | Platform administrator |

Anything the app signs up on its own is created as a **Consumer**:
`raw_user_meta_data` comes from the client at sign-up, so it is never trusted to
grant HOST or ADMIN. Promote the platform administrator afterwards:

```sql
update public.users set role = 'ADMIN' where email = 'admin@amperly.app';
```

#### Signing up from the app needs a working email sender

Sign-up returns a session immediately only when the project does not require
confirmation. With **Confirm email** on, GoTrue creates the account and then waits
for the link to be opened — and until it is, the app cannot sign in at all. The
account shows up in Authentication with no profile and no data anywhere, which
looks exactly like a broken backend.

Check **Authentication → Providers → Email**. Either turn **Confirm email** off
for the pilot, or configure **SMTP**. Supabase's built-in sender only delivers to
the project's own team members, so with the defaults no pilot user will ever
receive the link.

The profile row is created either way, at the moment the account is created, so
the app works as soon as the user is able to sign in.

#### Deleting an account deletes its data

Delete the user in **Authentication → Users**. That is the only step: a trigger on
`auth.users` removes the profile and every row that account owned — vehicles, plans,
stops, battery updates, reservations, sessions, meter readings, invoices, payments,
disputes, chats, safety events, trusted contacts, notifications, Android Auto sessions,
and, for a host, their stations with their ports and opening hours. The rows of the
other party in a booking are not touched except where the booking itself goes with a
removed station.

Deleting the row from `public.users` in the SQL editor is **not** the same thing: it
only removes the profile. Delete the Auth account, and the app data goes with it.

What this does not reach is the copy already cached on a device. A phone that has
signed in keeps its Room rows until the app clears them, so wipe app data on a device
you are handing on.

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
  server. `invoices` have no client write policy at all, `payments` money fields
  are pinned by `prevent_payment_tampering()` (only the settlement functions can
  capture, refund or release), and the billing columns of `charging_sessions`
  are pinned by a trigger.
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
| `authorize_payment` | the consumer booking | Creates an authorization (a hold, not a charge). **Not called by this build:** no gateway is connected, so a booking is a free hold |
| `finalize_charging_session` | that reservation's consumer or host | Recomputed from the meter readings; writes the session and the receipt, closes the reservation, frees the port, and marks the invoice `PAID` only if a payment row exists (otherwise `ISSUED`) |
| `cancel_reservation` | that reservation's consumer or host | Applies the published late-cancellation policy server-side and releases any hold |
| `decide_station_approval` | admin | Approves or rejects a listing and notifies the host |
| `resolve_dispute_refund` | admin | Refunds the invoice's energy charge, refunds the payment, resolves the dispute |
| `freeze_dispute_payout` | admin | Holds the host's payout |
| `apply_host_enforcement` | admin | Records the enforcement action and pauses the station when the policy calls for it |

Booking is a function too: `create_reservation` takes a per-port advisory lock,
checks the requested window against live reservations, reads the station's real
tariff and inserts in one transaction. It is the only INSERT path into
`reservations` (there is no insert policy), and it caps a single hold at 12 hours
so a custom client cannot block a port indefinitely.

Each one checks who is calling before it writes, and the app calls it directly
from the save that needs it. There is no offline queue: a call that fails is
reported in the account screen's sync status instead of being replayed later.

Three things to keep in mind:

- **Run `schema.sql` as the table owner** — the Supabase SQL editor does this.
  The functions are `SECURITY DEFINER`, and the guard triggers treat a session
  whose `current_user` is neither `anon` nor `authenticated` as trusted. If the
  functions ended up owned by some other role, RLS would apply to their writes
  too and settlements would fail.
- **A refused write is reported, not queued.** The app holds no offline write
  queue, so a row the server refuses is logged and shown in the account screen's
  sync status; the local copy in Room stays but is not re-sent.
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

`"authUserId"` is why sections 1b and 1c exist. The column has no counterpart on
the Room entity, so a row built from the entity alone would arrive without it and
`users_insert_self` would refuse the insert. The app still creates its own profile
row on first sign-in, as a fallback for a project where those sections have not
been applied yet, and it sends that row straight to PostgREST with the server-only
column included.

---

## Troubleshooting

**`relation "public.users" does not exist` while running the file** — the copy you
pasted creates a function that reads `public.users` above the statement that
creates it. PostgreSQL parses and analyses the body of a `LANGUAGE SQL` function
when it is created, so the file has to be ordered tables-first. Sections 1b and 1c
are placed after section 1 for exactly that reason. The error quotes a line inside
the function, and nothing before it in the file was applied.

**"new row violates row-level security policy"** — the signed-in user has no
`public.users` row, so `current_app_user_id()` returned null. Re-run `schema.sql`:
the backfill at the end creates the missing profile for every existing Auth
account, and the `on_auth_user_created` trigger stops it happening again.

**The account is in Authentication but not in `public.users`** — this is the state
that makes the whole app look empty, because every policy resolves the caller
through `users."authUserId"`. Re-run `schema.sql` and read the table it prints at
the end: every Auth account must show an `app_user_id`.

**Queries return an empty list instead of an error** — that is RLS working
correctly: you are seeing zero rows because no policy grants you any. Same fix
as above.

**401 / "No API key found in request"** — `SUPABASE_PUBLISHABLE_KEY` is empty or
still the placeholder. Check `local.properties` and rebuild; `BuildConfig` values
are baked in at compile time.

**A new column or table is not visible to the API** — PostgREST caches the
schema. Run `notify pgrst, 'reload schema';`, or wait a few seconds and retry.

**Consumer discovery shows nothing** — discovery deliberately exposes only
stations with `"approvalStatus" = 'APPROVED'` and `"isPaused" = false`. A charger
stays invisible until an admin approves it.

**Testing policies by hand** — RLS applies to the API roles, not to you in the
SQL editor, so a query that works in the editor may still fail from the app. To
check what a signed-in user actually sees, impersonate them:

```sql
set local role authenticated;
set local request.jwt.claims = '{"sub":"<auth-user-uuid>"}';
select * from public.reservations;
reset role;
```
