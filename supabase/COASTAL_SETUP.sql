-- ============================================================================
--  Amperly — one-paste setup: security fix + administrator + coastal chargers
-- ============================================================================
--  Paste this WHOLE file into Supabase -> SQL Editor -> New query -> Run.
--
--  BEFORE YOU RUN IT: find the line
--      v_password text := 'CHANGE_ME_BEFORE_RUNNING';
--  in part 2 and replace the placeholder with a password of at least 12
--  characters. The script stops with an error if you do not.
--
--  It is the three files below, in the order they must run:
--    1. security_hardening.sql  (stops listing self-approval)
--    2. create_admin.sql        (admin@amperly.app)
--    3. coastal_stations.sql    (Mangaluru to Udupi, including Karkala)
--
--  Safe to re-run. The individual files stay the source of truth.
-- ============================================================================

-- ============================================================================
--  Amperly — close the listing self-approval hole
-- ============================================================================
--  Run AFTER schema.sql, in the Supabase SQL Editor. Safe to re-run.
--
--  The problem this fixes
--  ---------------------
--  A host owns their charger_stations row, and the RLS policies must let them
--  edit it. A policy can decide *which rows* a caller may write, but it cannot
--  say "but not these columns". So before this file, any signed-in account
--  could POST a station with:
--
--      "approvalStatus":  "APPROVED"
--      "isVerified":      true
--      "verificationLevel": "LEVEL_1"
--      "rating":          5.0
--
--  and it appeared in discovery immediately, marked as a verified-meter
--  charger, without ever reaching the admin queue. The same account could
--  PATCH an existing station to approve it, or rewrite its own rating and
--  reliability score, which feed the planner's "most reliable" preference.
--
--  The fix
--  -------
--  Review state is administrator-owned. A non-admin INSERT is forced to
--  PENDING / unverified / zero reputation; a non-admin UPDATE keeps the
--  existing review state, meter level, ownership and reputation, whatever the
--  request body says. The admin approval function runs as the table owner and
--  is unaffected.
--
--  This is deliberately a silent pin rather than an exception: the app sends a
--  whole row back when a host edits a price, and a stale isVerified value in
--  that row must not turn a normal edit into an error.
-- ============================================================================

create or replace function public.prevent_station_review_tampering()
returns trigger
language plpgsql
set search_path = public
as $$
begin
    -- The SQL editor, a migration, or a SECURITY DEFINER function (which runs
    -- as the table owner): trusted, and the only path that may decide review
    -- state.
    if public.is_trusted_sql_context() or public.is_platform_admin() then
        return new;
    end if;

    if tg_op = 'INSERT' then
        new."approvalStatus" := 'PENDING';
        new."isVerified"      := false;
        new."reviewNote"      := '';
        new.rating            := 0;
        new."reliabilityScore" := 0;
        new."incidentCount"   := 0;
        return new;
    end if;

    -- UPDATE: everything an attacker would change to skip review, get paid
    -- billing without a meter, or forge a good reputation.
    new."approvalStatus"    := old."approvalStatus";
    new."isVerified"        := old."isVerified";
    new."verificationLevel" := old."verificationLevel";
    new."reviewNote"        := old."reviewNote";
    new."hostId"            := old."hostId";
    new.rating              := old.rating;
    new."reliabilityScore"  := old."reliabilityScore";
    new."incidentCount"     := old."incidentCount";

    return new;
end;
$$;

drop trigger if exists prevent_station_review_tampering on public.charger_stations;
create trigger prevent_station_review_tampering
    before insert or update on public.charger_stations
    for each row execute function public.prevent_station_review_tampering();

-- Trigger-only function: not part of the API surface.
revoke all on function public.prevent_station_review_tampering() from public;


-- ============================================================================
--  Second hole: a party could resolve their own dispute
-- ============================================================================
--  The disputes UPDATE policy has to let both parties write the row, because
--  the host's answer lives on it. But a policy cannot exclude columns, so a host
--  could PATCH status='RESOLVED', refundAmount=5000, isPayoutFrozen=false, or a
--  consumer could mark their own dispute resolved. Money and outcome are
--  administrator-owned; the host may still write hostNotes.
-- ============================================================================

create or replace function public.prevent_dispute_self_resolution()
returns trigger
language plpgsql
set search_path = public
as $$
begin
    if public.is_trusted_sql_context() or public.is_platform_admin() then
        return new;
    end if;

    new.status              := old.status;
    new."refundAmount"      := old."refundAmount";
    new."resolutionNote"    := old."resolutionNote";
    new."isPayoutFrozen"    := old."isPayoutFrozen";
    new."enforcementAction" := old."enforcementAction";
    new."resolvedAtMs"      := old."resolvedAtMs";
    new."consumerId"        := old."consumerId";
    new."hostId"            := old."hostId";
    new."sessionId"         := old."sessionId";

    return new;
end;
$$;

drop trigger if exists prevent_dispute_self_resolution on public.disputes;
create trigger prevent_dispute_self_resolution
    before update on public.disputes
    for each row execute function public.prevent_dispute_self_resolution();

revoke all on function public.prevent_dispute_self_resolution() from public;


-- ============================================================================
--  Third hole: a booking could mark itself paid
-- ============================================================================
--  The reservation trigger already pins the slot, port, price and booking code.
--  It did not pin the payment columns, so either party could PATCH isPaid=true,
--  clear cancellationFee, or detach paymentId. Those are written by
--  authorize_payment() and the cancellation function, which run as the owner.
-- ============================================================================

create or replace function public.prevent_reservation_tampering()
returns trigger
language plpgsql
set search_path = public
as $$
begin
    if public.is_trusted_sql_context() or public.is_platform_admin() then
        return new;
    end if;

    if new."startTimeMs"    is distinct from old."startTimeMs"
       or new."endTimeMs"    is distinct from old."endTimeMs"
       or new."portId"       is distinct from old."portId"
       or new."stationId"    is distinct from old."stationId"
       or new."consumerId"   is distinct from old."consumerId"
       or new."pricePerKwh"  is distinct from old."pricePerKwh"
       or new."serviceFee"   is distinct from old."serviceFee"
       or new."gatewayFee"   is distinct from old."gatewayFee"
       or new."bookingCode"  is distinct from old."bookingCode"
       or new."isPaid"          is distinct from old."isPaid"
       or new."paymentId"       is distinct from old."paymentId"
       or new."cancellationFee" is distinct from old."cancellationFee" then
        raise exception 'A reservation slot, port, price and payment state are fixed when the booking is made.';
    end if;

    return new;
end;
$$;

revoke all on function public.prevent_reservation_tampering() from public;

-- ============================================================================
--  Verify: as a signed-in host, this must come back PENDING / false.
-- ============================================================================
--   insert into public.charger_stations (id, "hostId", name, "approvalStatus", "isVerified")
--   values ('self_approve_probe', public.current_app_user_id(), 'Probe', 'APPROVED', true);
--   select "approvalStatus", "isVerified" from public.charger_stations
--    where id = 'self_approve_probe';
--   delete from public.charger_stations where id = 'self_approve_probe';
-- ============================================================================


-- ============================================================================
--  Amperly — create the platform administrator
-- ============================================================================
--  Run AFTER schema.sql, in the Supabase SQL Editor. Safe to re-run: an
--  existing account with the same email gets its password reset and its role
--  re-applied instead of being duplicated.
--
--  Before running: set v_password below to the password you want. It is left as
--  a placeholder on purpose — a real password must never be committed, because
--  anyone who can read this repository could otherwise sign in as the platform
--  administrator of your live project. The script refuses to run while the
--  placeholder is still in place.
--
--  Email: admin@amperly.app (change v_email if you want a different address).
--
--  Why this is SQL and not the app
--  -------------------------------
--  The public sign-up endpoint always creates a CONSUMER, and the
--  prevent_privilege_escalation trigger refuses a role change from anyone who
--  is not already an admin. That is deliberate — otherwise any user could
--  promote themselves. Creating the first administrator therefore has to be a
--  trusted SQL action, which is what this file is.
--
--  The account is created directly in auth.users with a bcrypt password, the
--  same hash GoTrue writes, so email + password sign-in works normally.
-- ============================================================================

do $$
declare
    v_email    text := 'admin@amperly.app';
    v_password text := 'CHANGE_ME_BEFORE_RUNNING';
    v_name     text := 'Amperly Admin';
    v_uid      uuid;
begin
    if v_password = 'CHANGE_ME_BEFORE_RUNNING' or length(v_password) < 12 then
        raise exception 'Set v_password in create_admin.sql to a password of at least 12 characters, then run it again.';
    end if;

    -- pgcrypto (crypt / gen_salt) lives in the extensions schema on Supabase.
    perform set_config('search_path', 'public, extensions, auth', true);

    select a.id into v_uid
      from auth.users a
     where lower(a.email) = lower(v_email)
     limit 1;

    if v_uid is null then
        v_uid := gen_random_uuid();

        insert into auth.users (
            instance_id, id, aud, role, email, encrypted_password,
            email_confirmed_at, created_at, updated_at,
            raw_app_meta_data, raw_user_meta_data)
        values (
            '00000000-0000-0000-0000-000000000000',
            v_uid,
            'authenticated',
            'authenticated',
            v_email,
            crypt(v_password, gen_salt('bf')),
            now(), now(), now(),
            jsonb_build_object('provider', 'email',
                               'providers', jsonb_build_array('email')),
            jsonb_build_object('name', v_name));
    else
        update auth.users
           set encrypted_password = crypt(v_password, gen_salt('bf')),
               email_confirmed_at = coalesce(email_confirmed_at, now()),
               updated_at         = now()
         where id = v_uid;
    end if;

    -- Some GoTrue versions also require the email identity row for password
    -- sign-in. If this schema differs, skip it: the password grant still
    -- resolves through auth.users.
    begin
        insert into auth.identities (id, user_id, identity_data, provider,
            provider_id, last_sign_in_at, created_at, updated_at)
        values (gen_random_uuid(), v_uid,
                jsonb_build_object('sub', v_uid::text, 'email', v_email),
                'email', v_uid::text, now(), now(), now())
        on conflict do nothing;
    exception when others then
        raise notice 'Identity row skipped (%): password sign-in still uses auth.users.', sqlerrm;
    end;

    -- The on_auth_user_created trigger normally creates the profile. This call
    -- covers a project where the trigger was installed after the account, and
    -- links a seeded profile by email if one exists.
    perform public.ensure_app_user(v_uid, v_email, jsonb_build_object('name', v_name));

    update public.users
       set role                 = 'ADMIN',
           name                 = v_name,
           email                = v_email,
           "verificationStatus" = 'VERIFIED',
           "isBlocked"          = false
     where "authUserId" = v_uid
        or lower(email) = lower(v_email);

    raise notice 'Administrator ready: %', v_email;
end $$;

-- ============================================================================
--  Verify — role must read ADMIN and linked must be true.
-- ============================================================================
select u.id, u.email, u.role, u."authUserId" is not null as linked
  from public.users u
 where lower(u.email) = 'admin@amperly.app';
-- ============================================================================


-- ============================================================================
--  Amperly — coastal charging corridor: Mangaluru → Udupi (via Karkala)
-- ============================================================================
--  Run AFTER schema.sql and create_admin.sql, in the Supabase SQL Editor.
--  Safe to re-run: every insert is guarded by ON CONFLICT DO NOTHING.
--
--  Nine live stations along NH-66 and the Karkala road, each with real ports and
--  a seven-day availability schedule, plus one listing left PENDING so the admin
--  desk has a real item to verify on first use.
--
--  Every station is owned by the platform administrator account created by
--  create_admin.sql, so you can verify, pause or reject them yourself from the
--  admin desk.
--
--  Verification levels are deliberately mixed:
--    LEVEL_1 / LEVEL_2 — paid meter billing enabled once approved
--    LEVEL_3           — discovery only (Kaup Beach Road: no verified meter)
-- ============================================================================

do $$
declare
    v_host  text;
    v_host_name text;
    v_now   bigint := (extract(epoch from now()) * 1000)::bigint;
begin
    select u.id, coalesce(u.name, 'Amperly Ops')
      into v_host, v_host_name
      from public.users u
     where lower(u.email) = 'admin@amperly.app'
     limit 1;

    if v_host is null then
        raise exception 'Create the administrator account first: run create_admin.sql.';
    end if;

    -- ------------------------------------------------------------- Mangaluru
    insert into public.charger_stations (id, "hostId", "hostName", name, address,
        latitude, longitude, "locationType", "operatingHours", "pricePerKwh", "serviceFee",
        "gatewayFee", "verificationLevel", "isVerified", "isPaused", "approvalStatus",
        "reviewNote", "connectorTypes", "maxPowerKw", "isDcCapable", "portCount",
        "accessRules", rating, "reliabilityScore", "incidentCount", "lastUpdatedMs")
    values
        ('st_coastal_mng_hub', v_host, v_host_name,
         'Hampankatta Charger Hub', 'Ground floor, Bharath Mall, Hampankatta, Mangaluru',
         12.8698, 74.8431, 'COMMERCIAL', '24/7', 20.0, 5.0, 4.0, 'LEVEL_1', true, false,
         'APPROVED', '', 'CCS_2_DC,TYPE_2_AC', 60.0, true, 3,
         'Mall basement parking. Show your booking code at the boom gate.', 4.7, 93.0, 0, v_now),
        ('st_coastal_mng_kadri', v_host, v_host_name,
         'Kadri City Charger', 'Kadri Park Road, Mangaluru',
         12.8890, 74.8470, 'PARKING', '07:00 - 23:00', 17.0, 5.0, 4.0, 'LEVEL_1', true, false,
         'APPROVED', '', 'TYPE_2_AC', 11.0, false, 2,
         'Paid parking bay. The attendant releases the charger on request.', 4.5, 91.0, 0, v_now),
        -- ------------------------------------------------------------ NH-66
        ('st_coastal_surathkal', v_host, v_host_name,
         'Surathkal NITK Charger', 'NITK Main Gate, Surathkal',
         13.0108, 74.7943, 'CAMPUS', '06:00 - 22:00', 16.0, 5.0, 4.0, 'LEVEL_2', true, false,
         'APPROVED', '', 'TYPE_2_AC,CCS_2_DC', 30.0, true, 2,
         'Campus vehicle pass or a visitor entry at the main gate.', 4.8, 94.0, 0, v_now),
        ('st_coastal_mulki', v_host, v_host_name,
         'Mulki Highway Charger', 'NH-66, Mulki',
         13.0910, 74.7935, 'COMMERCIAL', '24/7', 21.0, 6.0, 4.0, 'LEVEL_1', true, false,
         'APPROVED', '', 'CCS_2_DC,CHADEMO', 50.0, true, 2,
         'Open to the public. Attendant on site between 06:00 and 22:00.', 4.6, 92.0, 0, v_now),
        ('st_coastal_padubidri', v_host, v_host_name,
         'Padubidri Service Road Charger', 'HP Petrol Pump, NH-66, Padubidri',
         13.1339, 74.7520, 'PETROL_PUMP', '05:00 - 23:00', 19.0, 5.0, 4.0, 'LEVEL_1', true, false,
         'APPROVED', '', 'CCS_2_DC', 50.0, true, 1,
         'Ask the pump attendant to unlock the charger.', 4.4, 90.0, 0, v_now),
        -- -------------------------------------------------------------- Kaup
        ('st_coastal_kaup', v_host, v_host_name,
         'Kaup Beach Road Charger', 'Beach Road, Kaup',
         13.2246, 74.7460, 'HOTEL', '07:00 - 22:00', 18.0, 0.0, 0.0, 'LEVEL_3', false, false,
         'APPROVED', '', 'TYPE_2_AC', 7.2, false, 1,
         'Reception holds the cable. No verified meter, so this one is discovery only.',
         4.2, 88.0, 0, v_now),
        -- ------------------------------------------------------------- Udupi
        ('st_coastal_udupi', v_host, v_host_name,
         'Udupi City Charger', 'Service Bus Stand Road, Udupi',
         13.3409, 74.7421, 'COMMERCIAL', '24/7', 20.0, 5.0, 4.0, 'LEVEL_1', true, false,
         'APPROVED', '', 'CCS_2_DC,TYPE_2_AC', 60.0, true, 3,
         'Public bay behind the bus stand. Two fast ports, one AC port.', 4.7, 93.0, 0, v_now),
        ('st_coastal_manipal', v_host, v_host_name,
         'Manipal Hospital Charger', 'Manipal Hospital, Madhav Nagar, Manipal',
         13.3525, 74.7869, 'OFFICE', '06:00 - 22:00', 18.0, 5.0, 4.0, 'LEVEL_2', true, false,
         'APPROVED', '', 'CCS_2_DC,TYPE_2_AC', 30.0, true, 2,
         'Visitor parking, level 1. Staff badge holders may stay overnight.', 4.8, 94.0, 0, v_now),
        -- ----------------------------------------------------------- Karkala
        ('st_coastal_karkala', v_host, v_host_name,
         'Karkala Town Charger', 'Near Karkala Bus Stand, Karkala',
         13.2143, 74.9920, 'COMMERCIAL', '06:00 - 23:00', 19.0, 5.0, 4.0, 'LEVEL_1', true, false,
         'APPROVED', '', 'CCS_2_DC,TYPE_2_AC', 50.0, true, 2,
         'Behind the bus stand, next to the two-wheeler parking.', 4.5, 91.0, 0, v_now),
        -- Sits in the verification queue on purpose, so the admin desk has a real
        -- listing to approve on first use. It stays out of discovery until then.
        ('st_coastal_karkala_new', v_host, v_host_name,
         'Karkala New Town Charger', 'New Town Layout, Karkala',
         13.2080, 74.9960, 'COMMERCIAL', '07:00 - 22:00', 18.0, 5.0, 4.0, 'LEVEL_1', false, false,
         'PENDING', '', 'TYPE_2_AC,CCS_2_DC', 30.0, true, 2,
         'New layout, behind the vegetable market. Meter certificate submitted with the listing.',
         0.0, 0.0, 0, v_now)
    on conflict (id) do nothing;

    -- ------------------------------------------------------------------ ports
    insert into public.charger_ports (id, "stationId", "portNumber", "connectorType",
        "powerKw", "isDc", status)
    values
        ('port_coastal_mng_hub_1',      'st_coastal_mng_hub',      '1', 'CCS_2_DC',  60.0, true,  'AVAILABLE'),
        ('port_coastal_mng_hub_2',      'st_coastal_mng_hub',      '2', 'CCS_2_DC',  60.0, true,  'AVAILABLE'),
        ('port_coastal_mng_hub_3',      'st_coastal_mng_hub',      '3', 'TYPE_2_AC', 7.2,  false, 'AVAILABLE'),
        ('port_coastal_mng_kadri_1',    'st_coastal_mng_kadri',    '1', 'TYPE_2_AC', 11.0, false, 'AVAILABLE'),
        ('port_coastal_mng_kadri_2',    'st_coastal_mng_kadri',    '2', 'TYPE_2_AC', 11.0, false, 'AVAILABLE'),
        ('port_coastal_surathkal_1',    'st_coastal_surathkal',    '1', 'TYPE_2_AC', 7.2,  false, 'AVAILABLE'),
        ('port_coastal_surathkal_2',    'st_coastal_surathkal',    '2', 'CCS_2_DC',  30.0, true,  'AVAILABLE'),
        ('port_coastal_mulki_1',        'st_coastal_mulki',        '1', 'CCS_2_DC',  50.0, true,  'AVAILABLE'),
        ('port_coastal_mulki_2',        'st_coastal_mulki',        '2', 'CHADEMO',   50.0, true,  'AVAILABLE'),
        ('port_coastal_padubidri_1',    'st_coastal_padubidri',    '1', 'CCS_2_DC',  50.0, true,  'AVAILABLE'),
        ('port_coastal_kaup_1',         'st_coastal_kaup',         '1', 'TYPE_2_AC', 7.2,  false, 'AVAILABLE'),
        ('port_coastal_udupi_1',        'st_coastal_udupi',        '1', 'CCS_2_DC',  60.0, true,  'AVAILABLE'),
        ('port_coastal_udupi_2',        'st_coastal_udupi',        '2', 'CCS_2_DC',  60.0, true,  'AVAILABLE'),
        ('port_coastal_udupi_3',        'st_coastal_udupi',        '3', 'TYPE_2_AC', 7.2,  false, 'AVAILABLE'),
        ('port_coastal_manipal_1',      'st_coastal_manipal',      '1', 'CCS_2_DC',  30.0, true,  'AVAILABLE'),
        ('port_coastal_manipal_2',      'st_coastal_manipal',      '2', 'TYPE_2_AC', 7.2,  false, 'MAINTENANCE'),
        ('port_coastal_karkala_1',      'st_coastal_karkala',      '1', 'CCS_2_DC',  50.0, true,  'AVAILABLE'),
        ('port_coastal_karkala_2',      'st_coastal_karkala',      '2', 'TYPE_2_AC', 7.2,  false, 'AVAILABLE'),
        ('port_coastal_karkala_new_1',  'st_coastal_karkala_new',  '1', 'CCS_2_DC',  30.0, true,  'AVAILABLE'),
        ('port_coastal_karkala_new_2',  'st_coastal_karkala_new',  '2', 'TYPE_2_AC', 7.2,  false, 'AVAILABLE')
    on conflict (id) do nothing;

    -- ---------------------------------------------------------- availability
    -- Seven days per port. Opening hours come from the station; a port in
    -- MAINTENANCE is blocked every day, which is the reason the app reports.
    insert into public.availability_schedules (id, "stationId", "portId", "dayOfWeek",
        "openMinutes", "closeMinutes", "isBlocked", "blockReason", "updatedAtMs")
    select p.id || '_d' || d.dow,
           p."stationId",
           p.id,
           d.dow,
           case p."stationId"
               when 'st_coastal_mng_hub'      then 0
               when 'st_coastal_mng_kadri'    then 420
               when 'st_coastal_surathkal'    then 360
               when 'st_coastal_mulki'        then 0
               when 'st_coastal_padubidri'    then 300
               when 'st_coastal_kaup'         then 420
               when 'st_coastal_udupi'        then 0
               when 'st_coastal_manipal'      then 360
               when 'st_coastal_karkala'      then 360
               when 'st_coastal_karkala_new'  then 420
           end,
           case p."stationId"
               when 'st_coastal_mng_hub'      then 1440
               when 'st_coastal_mng_kadri'    then 1380
               when 'st_coastal_surathkal'    then 1320
               when 'st_coastal_mulki'        then 1440
               when 'st_coastal_padubidri'    then 1380
               when 'st_coastal_kaup'         then 1320
               when 'st_coastal_udupi'        then 1440
               when 'st_coastal_manipal'      then 1320
               when 'st_coastal_karkala'      then 1380
               when 'st_coastal_karkala_new'  then 1320
           end,
           (p.status = 'MAINTENANCE'),
           case when p.status = 'MAINTENANCE' then 'Port under maintenance' else null end,
           v_now
    from public.charger_ports p
    cross join generate_series(1, 7) as d(dow)
    where p."stationId" in (
        'st_coastal_mng_hub', 'st_coastal_mng_kadri', 'st_coastal_surathkal',
        'st_coastal_mulki', 'st_coastal_padubidri', 'st_coastal_kaup',
        'st_coastal_udupi', 'st_coastal_manipal', 'st_coastal_karkala',
        'st_coastal_karkala_new')
    on conflict (id) do nothing;
end $$;

-- ============================================================================
--  Verify — expect 10 stations (9 APPROVED, 1 PENDING), 20 ports, 140 schedules.
-- ============================================================================
--   select count(*) from public.charger_stations where id like 'st_coastal_%';
--   select count(*) from public.charger_ports    where id like 'port_coastal_%';
--   select count(*) from public.availability_schedules where id like '%_d%'
--     and "stationId" like 'st_coastal_%';
-- ============================================================================
