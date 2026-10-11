-- ============================================================================
--  Amperly — Supabase / Postgres schema
-- ============================================================================
--  Paste this whole file into:  Supabase Dashboard -> SQL Editor -> New query
--  It is idempotent: safe to run more than once.
--
--  DESIGN NOTE — why the column names look unusual
--  ---------------------------------------------------------------------------
--  Every column name below is quoted camelCase and matches the Java field name
--  in app/src/main/java/com/amperly/app/data/local/entity/ exactly. None of the
--  Room entities use @ColumnInfo, so the Room/SQLite column already equals the
--  field name. By keeping the same names here:
--
--      PostgREST JSON key  ==  Java field name  ==  Room column
--
--  ...which means Gson deserialises PostgREST responses straight into the
--  existing entity classes and the app needs no DTO/mapping layer at all.
--  The cost is quoted identifiers in SQL. That is a deliberate trade.
--
--  Columns NOT present in the Room entities (authUserId, serverUpdatedAt) are
--  server-only: Gson silently ignores JSON keys it has no field for, so adding
--  them is safe.
--
--  Table names below are already snake_case, matching Room's @Entity(tableName).
-- ============================================================================


-- ---------------------------------------------------------------------------
-- 0. Helper functions
-- ---------------------------------------------------------------------------

-- True when the caller is a direct SQL session (the dashboard SQL editor, the
-- service role, a migration) rather than an API request. PostgREST always
-- connects as one of the two API roles below, so this reliably distinguishes
-- "trusted operator at a keyboard" from "someone holding the publishable key".
-- Deliberately SECURITY INVOKER (the default) so current_user is the caller.
create or replace function public.is_trusted_sql_context()
returns boolean
language sql
stable
as $$
    select current_user not in ('anon', 'authenticated')
$$;

-- The application user id (e.g. 'user_student_1') behind the current JWT.
-- SECURITY DEFINER so it can read public.users while RLS is active, which
-- avoids infinite policy recursion. search_path is pinned for safety.
create or replace function public.current_app_user_id()
returns text
language sql
stable
security definer
set search_path = public
as $$
    select u.id
    from public.users u
    where u."authUserId" = auth.uid()
    limit 1
$$;

create or replace function public.current_app_user_role()
returns text
language sql
stable
security definer
set search_path = public
as $$
    select u.role
    from public.users u
    where u."authUserId" = auth.uid()
    limit 1
$$;

create or replace function public.is_platform_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
    select coalesce(
        (select u.role = 'ADMIN'
         from public.users u
         where u."authUserId" = auth.uid()
         limit 1),
        false)
$$;

-- Stamps serverUpdatedAt on every UPDATE. The sync engine pulls rows where
-- serverUpdatedAt > last successful pull, so this is what makes incremental
-- sync possible.
create or replace function public.touch_server_updated_at()
returns trigger
language plpgsql
as $$
begin
    new."serverUpdatedAt" = now();
    return new;
end;
$$;

-- Blocks a signed-in user from promoting themselves to ADMIN or from clearing
-- their own block flag. Without this, a user could PATCH their own users row
-- and take over the platform — the users UPDATE policy alone cannot express
-- "but you may not change this column".
--
-- SECURITY INVOKER on purpose: is_trusted_sql_context() inspects current_user,
-- and inside a SECURITY DEFINER function current_user becomes the function
-- owner, which would make every request look trusted and defeat the check.
create or replace function public.prevent_privilege_escalation()
returns trigger
language plpgsql
set search_path = public
as $$
begin
    if public.is_trusted_sql_context() or public.is_platform_admin() then
        return new;
    end if;
    if new.role is distinct from old.role then
        raise exception 'Changing the role of a user is an administrator action.';
    end if;
    if new."isBlocked" is distinct from old."isBlocked" then
        raise exception 'Changing the blocked state of a user is an administrator action.';
    end if;
    if new."verificationStatus" is distinct from old."verificationStatus" then
        raise exception 'Changing a verification status is an administrator action.';
    end if;
    return new;
end;
$$;


-- ---------------------------------------------------------------------------
-- 1. Tables
--    23 tables, one per Room entity.
-- ---------------------------------------------------------------------------

-- users ---------------------------------------------------------------
create table if not exists public.users (
    id                  text primary key,
    "authUserId"        uuid unique references auth.users (id) on delete set null,
    name                text,
    email               text,
    phone               text,
    role                text,     -- CONSUMER, HOST, ADMIN
    "organizationName"  text,
    "verificationStatus" text,    -- UNVERIFIED, PENDING, VERIFIED
    "isBlocked"         boolean not null default false,
    "serverUpdatedAt"   timestamptz not null default now()
);

-- vehicles ------------------------------------------------------------
create table if not exists public.vehicles (
    id                              text primary key,
    "userId"                        text,
    make                            text,
    model                           text,
    variant                         text,
    "purchaseYear"                  integer,
    "batteryCapacityKwh"            double precision,
    "connectorType"                 text,
    "maxAcKw"                       double precision,
    "maxDcKw"                       double precision,
    "typicalEfficiencyKmPerKwh"     double precision,
    "batteryHealthPercent"          double precision,
    "efficiencyCorrectionPercent"   double precision,
    "minArrivalSocPercent"          integer,
    "maxChargeSocPercent"           integer,
    "licensePlate"                  text,
    "serverUpdatedAt"               timestamptz not null default now()
);

-- charger_stations ----------------------------------------------------
create table if not exists public.charger_stations (
    id                  text primary key,
    "hostId"            text,
    "hostName"          text,
    name                text,
    address             text,
    latitude            double precision,
    longitude           double precision,
    "locationType"      text,
    "operatingHours"    text,
    "pricePerKwh"       double precision,
    "serviceFee"        double precision,
    "gatewayFee"        double precision,
    "verificationLevel" text,     -- LEVEL_1_VERIFIED_MANUAL, LEVEL_2_SIMULATED_SMART_METER, LEVEL_3_NO_VERIFIED_METER
    "isVerified"        boolean not null default false,
    "isPaused"          boolean not null default false,
    "approvalStatus"    text,     -- PENDING, APPROVED, REJECTED
    "reviewNote"        text,
    "connectorTypes"    text,     -- comma separated, e.g. 'TYPE_2_AC,CCS_2_DC'
    "maxPowerKw"        double precision,
    "isDcCapable"       boolean not null default false,
    "portCount"         integer,
    "accessRules"       text,
    rating              double precision,
    "reliabilityScore"  double precision,
    "incidentCount"     integer,
    "lastUpdatedMs"     bigint,
    "serverUpdatedAt"   timestamptz not null default now()
);

-- charger_ports -------------------------------------------------------
create table if not exists public.charger_ports (
    id              text primary key,
    "stationId"     text,
    "portNumber"    text,
    "connectorType" text,
    "powerKw"       double precision,
    "isDc"          boolean not null default false,
    status          text,     -- AVAILABLE, OCCUPIED, MAINTENANCE, RESERVED
    "serverUpdatedAt" timestamptz not null default now()
);

-- availability_schedules ----------------------------------------------
create table if not exists public.availability_schedules (
    id              text primary key,
    "stationId"     text,
    "portId"        text,
    "dayOfWeek"     integer,   -- Calendar.MONDAY..SUNDAY (1..7)
    "openMinutes"   integer,   -- minutes from local midnight
    "closeMinutes"  integer,
    "isBlocked"     boolean not null default false,
    "blockReason"   text,
    "updatedAtMs"   bigint,
    "serverUpdatedAt" timestamptz not null default now()
);

-- reservations --------------------------------------------------------
create table if not exists public.reservations (
    id                text primary key,
    "consumerId"      text,
    "stationId"       text,
    "stationName"     text,
    "portId"          text,
    "portLabel"       text,
    "bookingCode"     text,
    "startTimeMs"     bigint,
    "endTimeMs"       bigint,
    status            text,   -- RESERVED, CHECKED_IN, CHARGING, COMPLETED, CANCELLED, EXPIRED, DISPUTED, REFUNDED
    "pricePerKwh"     double precision,
    "serviceFee"      double precision,
    "gatewayFee"      double precision,
    "cancellationFee" double precision,
    "isPaid"          boolean not null default false,
    "paymentId"       text,
    "checkedInAtMs"   bigint,
    "cancelledAtMs"   bigint,
    "createdAtMs"     bigint,
    "serverUpdatedAt" timestamptz not null default now()
);

-- charging_sessions ---------------------------------------------------
create table if not exists public.charging_sessions (
    id                    text primary key,
    "reservationId"       text,
    "consumerId"          text,
    "hostId"              text,
    "stationId"           text,
    "stationName"         text,
    "portId"              text,
    "startTimeMs"         bigint,
    "endTimeMs"           bigint,
    "startingMeterKwh"    double precision,
    "endingMeterKwh"      double precision,
    "verifiedKwhConsumed" double precision,
    "energyCharge"        double precision,
    "serviceFee"          double precision,
    "gatewayFee"          double precision,
    "totalPaid"           double precision,
    status                text,
    "meterReadingId"      text,
    "invoiceId"           text,
    "isMeterSimulated"    boolean not null default false,
    "verificationLevel"   text,
    "serverUpdatedAt"     timestamptz not null default now()
);

-- meter_readings ------------------------------------------------------
create table if not exists public.meter_readings (
    id                  text primary key,
    "sessionId"         text,
    "stationId"         text,
    "startMeterKwh"     double precision,
    "endMeterKwh"       double precision,
    "photoEvidenceUri"  text,
    "verificationLevel" text,
    "timestampMs"       bigint,
    "isSimulated"       boolean not null default false,
    "serverUpdatedAt"   timestamptz not null default now()
);

-- invoices ------------------------------------------------------------
create table if not exists public.invoices (
    id              text primary key,
    "sessionId"     text,
    "consumerId"    text,
    "hostId"        text,
    "stationName"   text,
    "verifiedKwh"   double precision,
    "energyCharge"  double precision,
    "serviceFee"    double precision,
    "gatewayFee"    double precision,
    adjustment      double precision,
    "adjustmentNote" text,
    "finalTotal"    double precision,
    "paymentId"     text,
    status          text,   -- ISSUED, PARTIALLY_REFUNDED, REFUNDED, PAID
    "issuedAtMs"    bigint,
    "serverUpdatedAt" timestamptz not null default now()
);

-- payments ------------------------------------------------------------
create table if not exists public.payments (
    id                    text primary key,
    "reservationId"       text,
    "sessionId"           text,
    "consumerId"          text,
    "hostId"              text,
    "idempotencyKey"      text unique,
    gateway               text,
    "gatewayReference"    text,
    "authorizedAmount"    double precision,
    "capturedAmount"      double precision,
    "refundedAmount"      double precision,
    "lateCancellationFee" double precision,
    status                text,  -- AUTHORIZED, CAPTURED, FAILED, REFUNDED, RELEASED
    "failureReason"       text,
    "createdAtMs"         bigint,
    "updatedAtMs"         bigint,
    "serverUpdatedAt"     timestamptz not null default now()
);

-- route_plans ---------------------------------------------------------
create table if not exists public.route_plans (
    id                  text primary key,
    "consumerId"        text,
    "vehicleId"         text,
    origin              text,
    destination         text,
    "originLat"         double precision,
    "originLng"         double precision,
    "destinationLat"    double precision,
    "destinationLng"    double precision,
    "corridorKm"        double precision,
    preference          text,  -- FASTEST, CHEAPEST, RELIABLE, SHORTEST_DETOUR
    "totalDistanceKm"   double precision,
    "driveMinutes"      integer,
    "detourMinutes"     integer,
    "chargingMinutes"   integer,
    "totalJourneyMinutes" integer,
    "plannedStartSoc"   integer,
    "arrivalSocTarget"  integer,
    "isSocAuthoritative" boolean not null default false,
    assumptions         text,
    confidence          text,  -- HIGH, MEDIUM, LOW
    status              text,  -- DRAFT, ACTIVE, COMPLETED, CANCELLED
    "createdAtMs"       bigint,
    "updatedAtMs"       bigint,
    "serverUpdatedAt"   timestamptz not null default now()
);

-- route_stops ---------------------------------------------------------
create table if not exists public.route_stops (
    id                    text primary key,
    "planId"              text,
    "sequence"            integer,
    "stationId"           text,
    "stationName"         text,
    "isBackup"            boolean not null default false,
    "isReachable"         boolean not null default false,
    "distanceAlongRouteKm" double precision,
    "detourKm"            double precision,
    "detourMinutes"       integer,
    "arrivalSoc"          integer,
    "departureSoc"        integer,
    "energyAddedKwh"      double precision,
    "chargingMinutes"     integer,
    "estimatedCost"       double precision,
    "recommendationReason" text,
    "reservationId"       text,
    "serverUpdatedAt"     timestamptz not null default now()
);

-- trip_estimates ------------------------------------------------------
create table if not exists public.trip_estimates (
    id                    text primary key,
    "planId"              text,
    "vehicleId"           text,
    "segmentDistanceKm"   double precision,
    "estimatedDrainKwh"   double precision,
    "actualDrainKwh"      double precision,
    "estimatedArrivalSoc" integer,
    "actualArrivalSoc"    integer,
    confidence            text,
    notes                 text,
    "createdAtMs"         bigint,
    "serverUpdatedAt"     timestamptz not null default now()
);

-- battery_updates -----------------------------------------------------
create table if not exists public.battery_updates (
    id                    text primary key,
    "vehicleId"           text,
    "tripPlanId"          text,
    "estimatedSoc"        integer,
    "actualDashboardSoc"  integer,
    latitude              double precision,
    longitude             double precision,
    "timestampMs"         bigint,
    "serverUpdatedAt"     timestamptz not null default now()
);

-- communication_threads -----------------------------------------------
create table if not exists public.communication_threads (
    id                    text primary key,
    "reservationId"       text,
    "consumerId"          text,
    "consumerName"        text,
    "hostId"              text,
    "hostName"            text,
    "maskedConsumerNumber" text,
    "maskedHostNumber"    text,
    "isReported"          boolean not null default false,
    "isBlocked"           boolean not null default false,
    "isChatEnabled"       boolean not null default true,
    "createdAtMs"         bigint,
    "expiresAtMs"         bigint,
    "serverUpdatedAt"     timestamptz not null default now()
);

-- chat_messages -------------------------------------------------------
create table if not exists public.chat_messages (
    id              text primary key,
    "threadId"      text,
    "reservationId" text,
    "senderId"      text,
    "receiverId"    text,
    "messageText"   text,
    "createdAtMs"   bigint,
    "isRead"        boolean not null default false,
    "isReported"    boolean not null default false,
    "expiresAtMs"   bigint,
    "serverUpdatedAt" timestamptz not null default now()
);

-- safety_events -------------------------------------------------------
create table if not exists public.safety_events (
    id                            text primary key,
    "consumerId"                  text,
    "stationId"                   text,
    "emergencyType"               text,
    "isLiveLocationSharingActive" boolean not null default false,
    "trustedContactPhone"         text,
    "expiresAtMs"                 bigint,
    "createdAtMs"                 bigint,
    "serverUpdatedAt"             timestamptz not null default now()
);

-- trusted_contacts ----------------------------------------------------
create table if not exists public.trusted_contacts (
    id            text primary key,
    "userId"      text,
    name          text,
    phone         text,
    "serverUpdatedAt" timestamptz not null default now()
);

-- reports -------------------------------------------------------------
create table if not exists public.reports (
    id                text primary key,
    "reporterId"      text,
    "reporterName"    text,
    "targetStationId" text,
    "targetHostId"    text,
    "sessionId"       text,
    "reportType"      text,
    description       text,
    status            text,   -- OPEN, REVIEWED, RESOLVED
    "createdAtMs"     bigint,
    "serverUpdatedAt" timestamptz not null default now()
);

-- disputes ------------------------------------------------------------
create table if not exists public.disputes (
    id                  text primary key,
    "sessionId"         text,
    "consumerId"        text,
    "consumerName"      text,
    "hostId"            text,
    "stationId"         text,
    "stationName"       text,
    reason              text,
    "consumerNotes"     text,
    "hostNotes"         text,
    evidence            text,
    status              text,
    "enforcementAction" text,   -- NONE, WARNING, FINE, SUSPENSION, BAN
    "refundAmount"      double precision,
    "resolutionNote"    text,
    "isPayoutFrozen"    boolean not null default false,
    "createdAtMs"       bigint,
    "resolvedAtMs"      bigint,
    "serverUpdatedAt"   timestamptz not null default now()
);

-- host_enforcements ---------------------------------------------------
create table if not exists public.host_enforcements (
    id              text primary key,
    "hostId"        text,
    "stationId"     text,
    "actionType"    text,   -- WARNING, FINE, SUSPENSION, BAN
    reason          text,
    "fineAmount"    double precision,
    "createdAtMs"   bigint,
    "serverUpdatedAt" timestamptz not null default now()
);

-- notifications -------------------------------------------------------
create table if not exists public.notifications (
    id            text primary key,
    "userId"      text,
    title         text,
    message       text,
    "isRead"      boolean not null default false,
    "createdAtMs" bigint,
    "serverUpdatedAt" timestamptz not null default now()
);

-- android_auto_sessions -----------------------------------------------
create table if not exists public.android_auto_sessions (
    id                    text primary key,
    "userId"              text,
    "vehicleId"           text,
    "planId"              text,
    "lastTemplateShown"   text,
    "lastSocUpdatePercent" integer,
    "connectedAtMs"       bigint,
    "lastSocUpdateAtMs"   bigint,
    "disconnectedAtMs"    bigint,
    "serverUpdatedAt"     timestamptz not null default now()
);


-- ---------------------------------------------------------------------------
-- 2. Indexes
--    serverUpdatedAt on every table powers the incremental sync pull.
--    The rest cover the ownership lookups used by both the policies and the app.
-- ---------------------------------------------------------------------------

do $$
declare t text;
begin
    foreach t in array array[
        'users','vehicles','charger_stations','charger_ports','availability_schedules',
        'reservations','charging_sessions','meter_readings','invoices','payments',
        'route_plans','route_stops','trip_estimates','battery_updates',
        'communication_threads','chat_messages','safety_events','trusted_contacts',
        'reports','disputes','host_enforcements','notifications','android_auto_sessions'
    ] loop
        execute format('create index if not exists %I on public.%I ("serverUpdatedAt")',
                       'idx_' || t || '_server_updated_at', t);
    end loop;
end $$;

create index if not exists idx_users_auth_user_id       on public.users ("authUserId");
create index if not exists idx_vehicles_user            on public.vehicles ("userId");
create index if not exists idx_stations_host            on public.charger_stations ("hostId");
create index if not exists idx_stations_discovery       on public.charger_stations ("approvalStatus", "isPaused");
create index if not exists idx_ports_station            on public.charger_ports ("stationId");
create index if not exists idx_schedules_station        on public.availability_schedules ("stationId", "dayOfWeek");
create index if not exists idx_reservations_consumer    on public.reservations ("consumerId");
create index if not exists idx_reservations_station     on public.reservations ("stationId", "startTimeMs");
create index if not exists idx_reservations_port        on public.reservations ("portId", "startTimeMs");
create index if not exists idx_sessions_consumer        on public.charging_sessions ("consumerId");
create index if not exists idx_sessions_host            on public.charging_sessions ("hostId");
create index if not exists idx_meter_readings_session   on public.meter_readings ("sessionId");
create index if not exists idx_invoices_consumer        on public.invoices ("consumerId");
create index if not exists idx_invoices_host            on public.invoices ("hostId");
create index if not exists idx_payments_consumer        on public.payments ("consumerId");
create index if not exists idx_route_plans_consumer     on public.route_plans ("consumerId");
create index if not exists idx_route_stops_plan         on public.route_stops ("planId", "sequence");
create index if not exists idx_trip_estimates_plan      on public.trip_estimates ("planId");
create index if not exists idx_battery_updates_vehicle  on public.battery_updates ("vehicleId");
create index if not exists idx_threads_consumer         on public.communication_threads ("consumerId");
create index if not exists idx_threads_host             on public.communication_threads ("hostId");
create index if not exists idx_chat_messages_thread     on public.chat_messages ("threadId", "createdAtMs");
create index if not exists idx_safety_events_consumer   on public.safety_events ("consumerId");
create index if not exists idx_trusted_contacts_user    on public.trusted_contacts ("userId");
create index if not exists idx_reports_reporter         on public.reports ("reporterId");
create index if not exists idx_reports_station          on public.reports ("targetStationId");
create index if not exists idx_disputes_consumer        on public.disputes ("consumerId");
create index if not exists idx_disputes_host            on public.disputes ("hostId");
create index if not exists idx_enforcements_host        on public.host_enforcements ("hostId");
create index if not exists idx_notifications_user       on public.notifications ("userId");
create index if not exists idx_auto_sessions_user       on public.android_auto_sessions ("userId");


-- ---------------------------------------------------------------------------
-- 3. serverUpdatedAt triggers
-- ---------------------------------------------------------------------------

do $$
declare t text;
begin
    foreach t in array array[
        'users','vehicles','charger_stations','charger_ports','availability_schedules',
        'reservations','charging_sessions','meter_readings','invoices','payments',
        'route_plans','route_stops','trip_estimates','battery_updates',
        'communication_threads','chat_messages','safety_events','trusted_contacts',
        'reports','disputes','host_enforcements','notifications','android_auto_sessions'
    ] loop
        execute format('drop trigger if exists touch_server_updated_at on public.%I', t);
        execute format('create trigger touch_server_updated_at before update on public.%I '
                       'for each row execute function public.touch_server_updated_at()', t);
    end loop;
end $$;

drop trigger if exists prevent_privilege_escalation on public.users;
create trigger prevent_privilege_escalation
    before update on public.users
    for each row execute function public.prevent_privilege_escalation();


-- ---------------------------------------------------------------------------
-- 4. Row Level Security
--    RLS is enabled on EVERY table before any policy is written, so there is no
--    window in which a table is reachable without policies.
-- ---------------------------------------------------------------------------

do $$
declare t text;
begin
    foreach t in array array[
        'users','vehicles','charger_stations','charger_ports','availability_schedules',
        'reservations','charging_sessions','meter_readings','invoices','payments',
        'route_plans','route_stops','trip_estimates','battery_updates',
        'communication_threads','chat_messages','safety_events','trusted_contacts',
        'reports','disputes','host_enforcements','notifications','android_auto_sessions'
    ] loop
        execute format('alter table public.%I enable row level security', t);
    end loop;
end $$;


-- ---- users ---------------------------------------------------------------
drop policy if exists users_select_self_or_admin on public.users;
create policy users_select_self_or_admin on public.users
    for select to authenticated
    using (id = public.current_app_user_id() or public.is_platform_admin());

drop policy if exists users_update_self_or_admin on public.users;
create policy users_update_self_or_admin on public.users
    for update to authenticated
    using (id = public.current_app_user_id() or public.is_platform_admin())
    with check (id = public.current_app_user_id() or public.is_platform_admin());

-- Self-registration. A user may create their own row once they hold an auth
-- account, but only as a Consumer or Host: ADMIN is deliberately excluded, and
-- the prevent_privilege_escalation() trigger stops it being set afterwards.
drop policy if exists users_insert_self on public.users;
create policy users_insert_self on public.users
    for insert to authenticated
    with check ("authUserId" = auth.uid() and role in ('CONSUMER', 'HOST'));

drop policy if exists users_admin_insert on public.users;
create policy users_admin_insert on public.users
    for insert to authenticated
    with check (public.is_platform_admin());

drop policy if exists users_admin_delete on public.users;
create policy users_admin_delete on public.users
    for delete to authenticated
    using (public.is_platform_admin());


-- ---- vehicles ------------------------------------------------------------
drop policy if exists vehicles_select_own on public.vehicles;
create policy vehicles_select_own on public.vehicles
    for select to authenticated
    using ("userId" = public.current_app_user_id() or public.is_platform_admin());

drop policy if exists vehicles_write_own on public.vehicles;
create policy vehicles_write_own on public.vehicles
    for all to authenticated
    using ("userId" = public.current_app_user_id() or public.is_platform_admin())
    with check ("userId" = public.current_app_user_id() or public.is_platform_admin());


-- ---- charger_stations ----------------------------------------------------
-- Discovery is intentionally readable by anon: a charger listing is public
-- information, like a map pin. Only approved, unpaused stations are exposed.
drop policy if exists stations_read_public on public.charger_stations;
create policy stations_read_public on public.charger_stations
    for select to anon, authenticated
    using ("approvalStatus" = 'APPROVED' and "isPaused" = false);

drop policy if exists stations_read_own_or_admin on public.charger_stations;
create policy stations_read_own_or_admin on public.charger_stations
    for select to authenticated
    using ("hostId" = public.current_app_user_id() or public.is_platform_admin());

drop policy if exists stations_insert_host on public.charger_stations;
create policy stations_insert_host on public.charger_stations
    for insert to authenticated
    with check ("hostId" = public.current_app_user_id() or public.is_platform_admin());

drop policy if exists stations_update_own_or_admin on public.charger_stations;
create policy stations_update_own_or_admin on public.charger_stations
    for update to authenticated
    using ("hostId" = public.current_app_user_id() or public.is_platform_admin())
    with check ("hostId" = public.current_app_user_id() or public.is_platform_admin());

drop policy if exists stations_delete_own_or_admin on public.charger_stations;
create policy stations_delete_own_or_admin on public.charger_stations
    for delete to authenticated
    using ("hostId" = public.current_app_user_id() or public.is_platform_admin());


-- ---- charger_ports -------------------------------------------------------
drop policy if exists ports_read_public on public.charger_ports;
create policy ports_read_public on public.charger_ports
    for select to anon, authenticated
    using (exists (select 1 from public.charger_stations s
                   where s.id = "stationId"
                     and s."approvalStatus" = 'APPROVED'
                     and s."isPaused" = false));

drop policy if exists ports_write_host_or_admin on public.charger_ports;
create policy ports_write_host_or_admin on public.charger_ports
    for all to authenticated
    using (exists (select 1 from public.charger_stations s
                   where s.id = "stationId" and s."hostId" = public.current_app_user_id())
           or public.is_platform_admin())
    with check (exists (select 1 from public.charger_stations s
                        where s.id = "stationId" and s."hostId" = public.current_app_user_id())
                or public.is_platform_admin());


-- ---- availability_schedules ---------------------------------------------
drop policy if exists schedules_read_public on public.availability_schedules;
create policy schedules_read_public on public.availability_schedules
    for select to anon, authenticated
    using (exists (select 1 from public.charger_stations s
                   where s.id = "stationId"
                     and s."approvalStatus" = 'APPROVED'
                     and s."isPaused" = false));

drop policy if exists schedules_write_host_or_admin on public.availability_schedules;
create policy schedules_write_host_or_admin on public.availability_schedules
    for all to authenticated
    using (exists (select 1 from public.charger_stations s
                   where s.id = "stationId" and s."hostId" = public.current_app_user_id())
           or public.is_platform_admin())
    with check (exists (select 1 from public.charger_stations s
                        where s.id = "stationId" and s."hostId" = public.current_app_user_id())
                or public.is_platform_admin());


-- ---- reservations --------------------------------------------------------
drop policy if exists reservations_read_parties on public.reservations;
create policy reservations_read_parties on public.reservations
    for select to authenticated
    using ("consumerId" = public.current_app_user_id()
           or exists (select 1 from public.charger_stations s
                      where s.id = "stationId" and s."hostId" = public.current_app_user_id())
           or public.is_platform_admin());

drop policy if exists reservations_insert_consumer on public.reservations;
create policy reservations_insert_consumer on public.reservations
    for insert to authenticated
    with check ("consumerId" = public.current_app_user_id() or public.is_platform_admin());

-- Both the consumer and the station host legitimately move a reservation's
-- status (check-in by the host, cancellation by the consumer).
drop policy if exists reservations_update_parties on public.reservations;
create policy reservations_update_parties on public.reservations
    for update to authenticated
    using ("consumerId" = public.current_app_user_id()
           or exists (select 1 from public.charger_stations s
                      where s.id = "stationId" and s."hostId" = public.current_app_user_id())
           or public.is_platform_admin())
    with check ("consumerId" = public.current_app_user_id()
           or exists (select 1 from public.charger_stations s
                      where s.id = "stationId" and s."hostId" = public.current_app_user_id())
           or public.is_platform_admin());

drop policy if exists reservations_admin_delete on public.reservations;
create policy reservations_admin_delete on public.reservations
    for delete to authenticated
    using (public.is_platform_admin());


-- ---- charging_sessions ---------------------------------------------------
drop policy if exists sessions_read_parties on public.charging_sessions;
create policy sessions_read_parties on public.charging_sessions
    for select to authenticated
    using ("consumerId" = public.current_app_user_id()
           or "hostId" = public.current_app_user_id()
           or public.is_platform_admin());

-- Either party can create/advance a session: the host checks the car in, the
-- consumer completes it.
drop policy if exists sessions_write_parties on public.charging_sessions;
create policy sessions_write_parties on public.charging_sessions
    for all to authenticated
    using ("consumerId" = public.current_app_user_id()
           or "hostId" = public.current_app_user_id()
           or public.is_platform_admin())
    with check ("consumerId" = public.current_app_user_id()
           or "hostId" = public.current_app_user_id()
           or public.is_platform_admin());


-- ---- meter_readings ------------------------------------------------------
drop policy if exists meter_readings_read_parties on public.meter_readings;
create policy meter_readings_read_parties on public.meter_readings
    for select to authenticated
    using (exists (select 1 from public.charging_sessions cs
                   where cs.id = "sessionId"
                     and (cs."consumerId" = public.current_app_user_id()
                          or cs."hostId" = public.current_app_user_id()))
           or public.is_platform_admin());

-- Only the host (or an admin) records meter evidence; a consumer must never be
-- able to write the reading their own bill is calculated from.
drop policy if exists meter_readings_write_host on public.meter_readings;
create policy meter_readings_write_host on public.meter_readings
    for all to authenticated
    using (exists (select 1 from public.charger_stations s
                   where s.id = "stationId" and s."hostId" = public.current_app_user_id())
           or public.is_platform_admin())
    with check (exists (select 1 from public.charger_stations s
                        where s.id = "stationId" and s."hostId" = public.current_app_user_id())
                or public.is_platform_admin());


-- ---- invoices ------------------------------------------------------------
drop policy if exists invoices_read_parties on public.invoices;
create policy invoices_read_parties on public.invoices
    for select to authenticated
    using ("consumerId" = public.current_app_user_id()
           or "hostId" = public.current_app_user_id()
           or public.is_platform_admin());

-- Invoices and refunds are issued by the platform, not by the parties.
drop policy if exists invoices_write_admin on public.invoices;
create policy invoices_write_admin on public.invoices
    for all to authenticated
    using (public.is_platform_admin())
    with check (public.is_platform_admin());


-- ---- payments ------------------------------------------------------------
drop policy if exists payments_read_parties on public.payments;
create policy payments_read_parties on public.payments
    for select to authenticated
    using ("consumerId" = public.current_app_user_id()
           or "hostId" = public.current_app_user_id()
           or public.is_platform_admin());

drop policy if exists payments_insert_consumer on public.payments;
create policy payments_insert_consumer on public.payments
    for insert to authenticated
    with check ("consumerId" = public.current_app_user_id() or public.is_platform_admin());

-- A consumer may only authorise/release their own payment. Capture, refund and
-- settlement amounts are administrator actions.
drop policy if exists payments_update_consumer on public.payments;
create policy payments_update_consumer on public.payments
    for update to authenticated
    using ("consumerId" = public.current_app_user_id() or public.is_platform_admin())
    with check ("consumerId" = public.current_app_user_id() or public.is_platform_admin());


-- ---- route_plans ---------------------------------------------------------
drop policy if exists route_plans_own on public.route_plans;
create policy route_plans_own on public.route_plans
    for all to authenticated
    using ("consumerId" = public.current_app_user_id() or public.is_platform_admin())
    with check ("consumerId" = public.current_app_user_id() or public.is_platform_admin());


-- ---- route_stops ---------------------------------------------------------
drop policy if exists route_stops_own on public.route_stops;
create policy route_stops_own on public.route_stops
    for all to authenticated
    using (exists (select 1 from public.route_plans p
                   where p.id = "planId" and p."consumerId" = public.current_app_user_id())
           or public.is_platform_admin())
    with check (exists (select 1 from public.route_plans p
                        where p.id = "planId" and p."consumerId" = public.current_app_user_id())
                or public.is_platform_admin());


-- ---- trip_estimates ------------------------------------------------------
drop policy if exists trip_estimates_own on public.trip_estimates;
create policy trip_estimates_own on public.trip_estimates
    for all to authenticated
    using (exists (select 1 from public.route_plans p
                   where p.id = "planId" and p."consumerId" = public.current_app_user_id())
           or public.is_platform_admin())
    with check (exists (select 1 from public.route_plans p
                        where p.id = "planId" and p."consumerId" = public.current_app_user_id())
                or public.is_platform_admin());


-- ---- battery_updates -----------------------------------------------------
drop policy if exists battery_updates_own on public.battery_updates;
create policy battery_updates_own on public.battery_updates
    for all to authenticated
    using (exists (select 1 from public.vehicles v
                   where v.id = "vehicleId" and v."userId" = public.current_app_user_id())
           or public.is_platform_admin())
    with check (exists (select 1 from public.vehicles v
                        where v.id = "vehicleId" and v."userId" = public.current_app_user_id())
                or public.is_platform_admin());


-- ---- communication_threads ----------------------------------------------
-- Reservation-scoped: only the two participants.
drop policy if exists threads_read_participants on public.communication_threads;
create policy threads_read_participants on public.communication_threads
    for select to authenticated
    using ("consumerId" = public.current_app_user_id()
           or "hostId" = public.current_app_user_id()
           or public.is_platform_admin());

drop policy if exists threads_write_participants on public.communication_threads;
create policy threads_write_participants on public.communication_threads
    for all to authenticated
    using ("consumerId" = public.current_app_user_id()
           or "hostId" = public.current_app_user_id()
           or public.is_platform_admin())
    with check ("consumerId" = public.current_app_user_id()
           or "hostId" = public.current_app_user_id()
           or public.is_platform_admin());


-- ---- chat_messages -------------------------------------------------------
drop policy if exists chat_read_participants on public.chat_messages;
create policy chat_read_participants on public.chat_messages
    for select to authenticated
    using (exists (select 1 from public.communication_threads t
                   where t.id = "threadId"
                     and (t."consumerId" = public.current_app_user_id()
                          or t."hostId" = public.current_app_user_id()))
           or public.is_platform_admin());

drop policy if exists chat_write_participants on public.chat_messages;
create policy chat_write_participants on public.chat_messages
    for insert to authenticated
    with check (("senderId" = public.current_app_user_id()
                 and exists (select 1 from public.communication_threads t
                             where t.id = "threadId"
                               and (t."consumerId" = public.current_app_user_id()
                                    or t."hostId" = public.current_app_user_id())))
           or public.is_platform_admin());


-- ---- safety_events -------------------------------------------------------
drop policy if exists safety_events_own on public.safety_events;
create policy safety_events_own on public.safety_events
    for all to authenticated
    using ("consumerId" = public.current_app_user_id() or public.is_platform_admin())
    with check ("consumerId" = public.current_app_user_id() or public.is_platform_admin());


-- ---- trusted_contacts ----------------------------------------------------
drop policy if exists trusted_contacts_own on public.trusted_contacts;
create policy trusted_contacts_own on public.trusted_contacts
    for all to authenticated
    using ("userId" = public.current_app_user_id() or public.is_platform_admin())
    with check ("userId" = public.current_app_user_id() or public.is_platform_admin());


-- ---- reports -------------------------------------------------------------
drop policy if exists reports_read_reporter_or_admin on public.reports;
create policy reports_read_reporter_or_admin on public.reports
    for select to authenticated
    using ("reporterId" = public.current_app_user_id() or public.is_platform_admin());

-- Anyone may file a report; only an administrator may resolve one.
drop policy if exists reports_insert_self on public.reports;
create policy reports_insert_self on public.reports
    for insert to authenticated
    with check ("reporterId" = public.current_app_user_id() or public.is_platform_admin());

drop policy if exists reports_update_admin on public.reports;
create policy reports_update_admin on public.reports
    for update to authenticated
    using (public.is_platform_admin())
    with check (public.is_platform_admin());


-- ---- disputes ------------------------------------------------------------
drop policy if exists disputes_read_parties on public.disputes;
create policy disputes_read_parties on public.disputes
    for select to authenticated
    using ("consumerId" = public.current_app_user_id()
           or "hostId" = public.current_app_user_id()
           or public.is_platform_admin());

drop policy if exists disputes_insert_consumer on public.disputes;
create policy disputes_insert_consumer on public.disputes
    for insert to authenticated
    with check ("consumerId" = public.current_app_user_id() or public.is_platform_admin());

-- The host may add their response; resolution, refund and enforcement are
-- administrator actions enforced by the app.
drop policy if exists disputes_update_parties on public.disputes;
create policy disputes_update_parties on public.disputes
    for update to authenticated
    using ("consumerId" = public.current_app_user_id()
           or "hostId" = public.current_app_user_id()
           or public.is_platform_admin())
    with check ("consumerId" = public.current_app_user_id()
           or "hostId" = public.current_app_user_id()
           or public.is_platform_admin());


-- ---- host_enforcements ---------------------------------------------------
drop policy if exists enforcements_read_host_or_admin on public.host_enforcements;
create policy enforcements_read_host_or_admin on public.host_enforcements
    for select to authenticated
    using ("hostId" = public.current_app_user_id() or public.is_platform_admin());

drop policy if exists enforcements_write_admin on public.host_enforcements;
create policy enforcements_write_admin on public.host_enforcements
    for all to authenticated
    using (public.is_platform_admin())
    with check (public.is_platform_admin());


-- ---- notifications -------------------------------------------------------
drop policy if exists notifications_own_or_admin on public.notifications;
create policy notifications_own_or_admin on public.notifications
    for all to authenticated
    using ("userId" = public.current_app_user_id() or public.is_platform_admin())
    with check ("userId" = public.current_app_user_id() or public.is_platform_admin());


-- ---- android_auto_sessions ----------------------------------------------
drop policy if exists auto_sessions_own on public.android_auto_sessions;
create policy auto_sessions_own on public.android_auto_sessions
    for all to authenticated
    using ("userId" = public.current_app_user_id() or public.is_platform_admin())
    with check ("userId" = public.current_app_user_id() or public.is_platform_admin());


-- ---------------------------------------------------------------------------
-- 5. Grants
--    RLS filters rows; grants decide which verbs are reachable at all. Both are
--    required. The service_role bypasses RLS entirely — never ship that key.
-- ---------------------------------------------------------------------------

grant usage on schema public to anon, authenticated;

grant select, insert, update, delete on all tables in schema public to authenticated;

-- Anonymous visitors may browse charger listings (discovery) and nothing else.
grant select on public.charger_stations        to anon;
grant select on public.charger_ports           to anon;
grant select on public.availability_schedules  to anon;

grant execute on function public.current_app_user_id()      to anon, authenticated;
grant execute on function public.current_app_user_role()    to authenticated;
grant execute on function public.is_platform_admin()        to authenticated;
grant execute on function public.is_trusted_sql_context()   to anon, authenticated;

-- ============================================================================
--  Done. Next: supabase/pilot_seed.sql (optional demo data), then
--  supabase/README.md for the API key and auth-user linking steps.
-- ============================================================================
