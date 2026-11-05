-- ============================================================================
--  Amperly - demo charger stations for the Udupi coastal pilot
-- ============================================================================
--  Paste this whole file into: Supabase Dashboard -> SQL Editor -> New query
--  Run it AFTER schema.sql. It is safe to re-run.
--
--  What it creates
--  ---------------
--  17 pending, unpaused demo stations, owned by manvithudupa073@gmail.com:
--    * 4 around Nitte
--    * 4 around Karkala
--    * 9 along the Udupi -> Bajpe corridor (Udupi, Manipal, Kaup, Padubidri,
--      Mulki, Surathkal, Bajpe town and Mangalore International Airport)
--  Each station gets its AC/DC ports and opening hours for all seven days, so
--  the listings are complete the moment an administrator approves them.
--
--  Why the station rows are inserted as PENDING
--  ---------------------------------------------
--  The owner is a normal user, not the administrator. Sign in with the admin
--  account and approve the 17 listings from the verification queue; the normal
--  decide_station_approval() RPC then makes them live in discovery and sets
--  isVerified for the LEVEL_1/LEVEL_2 meter rows.
--
--  The SQL editor runs as the table owner, which public.is_trusted_sql_context()
--  treats as a trusted migration session. That is why the rows keep the PENDING
--  state written here instead of being forced to it by the review trigger.
--
--  Host profile
--  ------------
--  Stations are owned by the public.users row whose email is
--  manvithudupa073@gmail.com. If that profile does not exist, the file stops
--  with a clear message; sign in with the account once so the Auth trigger
--  creates the profile, then run it again. The account's role is not changed.
--
--  Re-running
--  ----------
--  Every row has a fixed demo_* id and is upserted, so a second run updates the
--  same stations instead of duplicating them. It does not delete stations or
--  ports you added yourself.
--
--  Removing the demo data later
--  ----------------------------
--    delete from public.availability_schedules where "stationId" like 'demo_%';
--    delete from public.charger_ports          where "stationId" like 'demo_%';
--    delete from public.charger_stations       where id like 'demo_%';
-- ============================================================================


-- ----------------------------------------------------------------------------
-- 1. Staging table: the station list, one row per charger location.
--    snake_case here; the insert below maps it to the quoted PostgREST columns.
-- ----------------------------------------------------------------------------
drop table if exists _amperly_demo_station_seed;

create temp table _amperly_demo_station_seed (
    id               text primary key,
    name             text not null,
    address          text not null,
    latitude         double precision not null,
    longitude        double precision not null,
    location_type    text not null,
    operating_hours  text not null,
    price_per_kwh    double precision not null,
    service_fee      double precision not null,
    gateway_fee      double precision not null,
    verification_level text not null,
    ac_ports         integer not null default 0,
    ac_kw            double precision not null default 7.4,
    dc_ports         integer not null default 0,
    dc_kw            double precision not null default 0,
    open_minutes     integer not null default 360,
    close_minutes    integer not null default 1380,
    access_rules     text not null default 'Contact the host on arrival.',
    rating           double precision not null default 4.5,
    reliability_score double precision not null default 94
);

insert into _amperly_demo_station_seed (
    id, name, address, latitude, longitude, location_type, operating_hours,
    price_per_kwh, service_fee, gateway_fee, verification_level,
    ac_ports, ac_kw, dc_ports, dc_kw, open_minutes, close_minutes,
    access_rules, rating, reliability_score
) values
-- ---------------------------------------------------------------------------
-- Nitte (Karkala taluk)
-- ---------------------------------------------------------------------------
('demo_nitte_university_gate',
 'Nitte University - Main Gate Charging Hub',
 'Nitte University Campus, Nitte, Karkala Taluk, Udupi District 574110',
 13.185800, 74.939200, 'CAMPUS', '05:00 - 23:30',
 16.0, 5.0, 4.0, 'LEVEL_2',
 6, 7.4, 2, 60, 300, 1410,
 'Campus visitors: register the vehicle at the gate. Public charging allowed.',
 4.7, 96),

('demo_nitte_hospital',
 'Nitte Hospital - Visitor Parking Chargers',
 'Justice K.S. Hegde Hospital, Nitte University Campus, Nitte 574110',
 13.185000, 74.943700, 'PARKING', 'Open 24 hours',
 18.0, 5.0, 4.0, 'LEVEL_1',
 2, 7.4, 2, 30, 0, 1440,
 'Visitor parking; use the hospital designated EV bays.',
 4.5, 93),

('demo_nitte_bus_stand',
 'Nitte Bus Stand - Public Charging Bays',
 'Nitte Bus Stand, Nitte, Karkala Taluk, Udupi District 574110',
 13.186900, 74.938600, 'PARKING', '05:30 - 22:30',
 15.0, 5.0, 4.0, 'LEVEL_1',
 4, 7.4, 0, 0, 330, 1350,
 'Public parking; first 30 minutes free while charging.',
 4.3, 92),

('demo_nitte_karkala_road',
 'Nitte - Karkala Road (SH-1) Charging Stop',
 'SH-1, Nitte - Karkala Road, near Doopadakatte, Udupi District 574110',
 13.195500, 74.949500, 'PETROL_PUMP', 'Open 24 hours',
 19.0, 5.0, 4.0, 'LEVEL_2',
 2, 7.4, 2, 50, 0, 1440,
 'Highway stop; card payment at the kiosk.',
 4.4, 94),

-- ---------------------------------------------------------------------------
-- Karkala
-- ---------------------------------------------------------------------------
('demo_karkala_bus_stand',
 'Karkala Bus Stand - Charging Bay',
 'Karkala Bus Stand, SH-1, Parpale, Karkala 574104',
 13.212885, 74.998586, 'PARKING', 'Open 24 hours',
 18.0, 5.0, 4.0, 'LEVEL_2',
 4, 7.4, 2, 60, 0, 1440,
 'Public bus stand parking; pay at the charging kiosk.',
 4.6, 95),

('demo_karkala_clock_tower',
 'Karkala Clock Tower - Town Centre Chargers',
 'Clock Tower Circle, Karkala Town, Karkala 574104',
 13.214541, 74.995186, 'COMMERCIAL', '06:00 - 23:00',
 17.0, 5.0, 4.0, 'LEVEL_1',
 2, 7.4, 1, 50, 360, 1380,
 'Town centre paid parking; chargers on the lower level.',
 4.4, 93),

('demo_attur_church',
 'Attur Church - Pilgrim Parking Chargers',
 'St. Lawrence Church, Attur Church Road, Attur, Karkala Taluk 574104',
 13.203536, 74.971022, 'PARKING', '05:00 - 22:00',
 16.0, 5.0, 4.0, 'LEVEL_1',
 4, 7.4, 2, 50, 300, 1320,
 'Pilgrim parking; please move the vehicle after charging.',
 4.5, 94),

('demo_karkala_moodabidri_road',
 'Karkala - Moodabidri Road Charging Stop',
 'Karkala - Moodabidri Road, near Nallur, Karkala Taluk 574104',
 13.150000, 74.995000, 'COMMERCIAL', 'Open 24 hours',
 21.0, 5.0, 4.0, 'LEVEL_2',
 2, 7.4, 2, 60, 0, 1440,
 'Highway stop with a 24-hour attendant.',
 4.3, 93),

-- ---------------------------------------------------------------------------
-- Udupi -> Bajpe corridor
-- ---------------------------------------------------------------------------
('demo_udupi_city_bus_stand',
 'Udupi City Bus Stand - Charging Hub',
 'Udupi City Bus Stand, Kavi Muddana Marg, Brahmagiri, Udupi 576101',
 13.340735, 74.748078, 'PARKING', 'Open 24 hours',
 18.0, 5.0, 4.0, 'LEVEL_2',
 4, 7.4, 2, 60, 0, 1440,
 'Bus stand parking; enter from Kavi Muddana Marg.',
 4.5, 95),

('demo_udupi_diana',
 'Diana Circle - Malpe - Manipal Road Chargers',
 'Diana Circle, Brahmagiri, Udupi 576101',
 13.344408, 74.749158, 'COMMERCIAL', '06:00 - 23:30',
 17.0, 5.0, 4.0, 'LEVEL_1',
 2, 7.4, 1, 50, 360, 1410,
 'Short-stay charging; ideal for a coffee stop.',
 4.4, 93),

('demo_manipal_kmc',
 'Manipal - KMC Hospital Parking Chargers',
 'KMC Hospital, Manipal, Udupi District 576104',
 13.351972, 74.787031, 'PARKING', 'Open 24 hours',
 19.0, 5.0, 4.0, 'LEVEL_2',
 4, 7.4, 2, 60, 0, 1440,
 'Hospital visitor parking; emergency bays are reserved.',
 4.6, 96),

('demo_kaup_beach',
 'Kaup Beach Road - Coastal Charging Stop',
 'Kaup Beach Road, Kaup, Udupi District 574106',
 13.218690, 74.738851, 'COMMERCIAL', '06:00 - 22:30',
 18.0, 5.0, 4.0, 'LEVEL_1',
 2, 7.4, 2, 50, 360, 1350,
 'Beach parking; keep the lighthouse access road clear.',
 4.5, 94),

('demo_padubidri_junction',
 'Padubidri Junction - NH-66 Charging Bay',
 'Padubidri Junction, NH-66, Udupi District 574111',
 13.141217, 74.770786, 'PETROL_PUMP', 'Open 24 hours',
 20.0, 5.0, 4.0, 'LEVEL_2',
 4, 7.4, 2, 60, 0, 1440,
 'NH-66 highway stop; toilets and refreshments on site.',
 4.6, 96),

('demo_mulki',
 'Mulki - Main Road Charging Point',
 'Main Road, Mulki, Dakshina Kannada 574154',
 13.090409, 74.787047, 'COMMERCIAL', '06:00 - 23:00',
 18.0, 5.0, 4.0, 'LEVEL_1',
 2, 7.4, 1, 50, 360, 1380,
 'Roadside charging; keep the service lane clear.',
 4.3, 92),

('demo_surathkal_nitk',
 'Surathkal - NITK Gate Charging Hub',
 'NITK Gate, NH-66, Surathkal, Mangaluru 575025',
 12.989348, 74.800207, 'CAMPUS', 'Open 24 hours',
 19.0, 5.0, 4.0, 'LEVEL_2',
 4, 7.4, 2, 60, 0, 1440,
 'Campus gate security may ask for vehicle details.',
 4.7, 96),

('demo_bajpe_town',
 'Bajpe Town - Bus Stand Chargers',
 'Bajpe Bus Stand, Bajpe, Mangaluru 574142',
 12.980744, 74.884153, 'PARKING', '06:00 - 23:00',
 18.0, 5.0, 4.0, 'LEVEL_1',
 2, 7.4, 2, 50, 360, 1380,
 'Town parking; short walk to the bus stand.',
 4.4, 93),

('demo_bajpe_airport',
 'Mangalore International Airport - Long-Stay Chargers',
 'Mangalore International Airport, Bajpe, Mangaluru 574142',
 12.954618, 74.884718, 'PARKING', 'Open 24 hours',
 24.0, 5.0, 4.0, 'LEVEL_2',
 4, 7.4, 4, 60, 0, 1440,
 'Airport long-stay parking; charging while you travel is allowed.',
 4.8, 97);


-- ----------------------------------------------------------------------------
-- 2. Stop early if the host profile does not exist. The app identifies a user
--    through public.users, so the Auth account must have that profile row.
-- ----------------------------------------------------------------------------
do $$
begin
    if not exists (
        select 1
          from public.users u
         where lower(coalesce(u.email, '')) = lower('manvithudupa073@gmail.com')
    ) then
        raise exception 'No profile with email manvithudupa073@gmail.com in public.users. Sign in with that account once, then run this file again.';
    end if;
end $$;


-- ----------------------------------------------------------------------------
-- 3. Stations. The owner is resolved by email so the listings belong to the
--    intended account and satisfy stations_insert_host if ever edited.
-- ----------------------------------------------------------------------------
with seed_host as (
    select u.id as host_id,
           coalesce(nullif(btrim(u.name), ''), 'Manvith Udupa') as host_name
      from public.users u
     where lower(coalesce(u.email, '')) = lower('manvithudupa073@gmail.com')
     order by (u."authUserId" is not null) desc, u.id
     limit 1
)
insert into public.charger_stations (
    id, "hostId", "hostName", name, address, latitude, longitude,
    "locationType", "operatingHours", "pricePerKwh", "serviceFee", "gatewayFee",
    "verificationLevel", "isVerified", "isPaused", "approvalStatus", "reviewNote",
    "connectorTypes", "maxPowerKw", "isDcCapable", "portCount", "accessRules",
    rating, "reliabilityScore", "incidentCount", "lastUpdatedMs"
)
select
    s.id,
    h.host_id,
    h.host_name,
    s.name,
    s.address,
    s.latitude,
    s.longitude,
    s.location_type,
    s.operating_hours,
    s.price_per_kwh,
    s.service_fee,
    s.gateway_fee,
    s.verification_level,
    false as is_verified,
    false as is_paused,
    'PENDING' as approval_status,
    'Demo seed - awaiting administrator approval.' as review_note,
    concat_ws(',',
        case when s.ac_ports > 0 then 'TYPE_2_AC' end,
        case when s.dc_ports > 0 then 'CCS_2_DC' end) as connector_types,
    greatest(s.ac_kw, s.dc_kw) as max_power_kw,
    s.dc_ports > 0 as is_dc_capable,
    s.ac_ports + s.dc_ports as port_count,
    s.access_rules,
    s.rating,
    s.reliability_score,
    0 as incident_count,
    (extract(epoch from now()) * 1000)::bigint as last_updated_ms
from _amperly_demo_station_seed s
cross join seed_host h
on conflict (id) do update set
    "hostId"            = excluded."hostId",
    "hostName"          = excluded."hostName",
    name                = excluded.name,
    address             = excluded.address,
    latitude            = excluded.latitude,
    longitude           = excluded.longitude,
    "locationType"      = excluded."locationType",
    "operatingHours"    = excluded."operatingHours",
    "pricePerKwh"       = excluded."pricePerKwh",
    "serviceFee"        = excluded."serviceFee",
    "gatewayFee"        = excluded."gatewayFee",
    "verificationLevel" = excluded."verificationLevel",
    "isVerified"        = excluded."isVerified",
    "isPaused"          = excluded."isPaused",
    "approvalStatus"    = excluded."approvalStatus",
    "reviewNote"        = excluded."reviewNote",
    "connectorTypes"    = excluded."connectorTypes",
    "maxPowerKw"        = excluded."maxPowerKw",
    "isDcCapable"       = excluded."isDcCapable",
    "portCount"         = excluded."portCount",
    "accessRules"       = excluded."accessRules",
    rating              = excluded.rating,
    "reliabilityScore"  = excluded."reliabilityScore",
    "incidentCount"     = excluded."incidentCount",
    "lastUpdatedMs"     = excluded."lastUpdatedMs";


-- ----------------------------------------------------------------------------
-- 4. Ports: one row per AC and DC connector, numbered AC-1, DC-1, ...
-- ----------------------------------------------------------------------------
insert into public.charger_ports (
    id, "stationId", "portNumber", "connectorType", "powerKw", "isDc", status
)
select
    s.id || '_ac' || g as id,
    s.id as station_id,
    'AC-' || g as port_number,
    'TYPE_2_AC' as connector_type,
    s.ac_kw as power_kw,
    false as is_dc,
    'AVAILABLE' as status
from _amperly_demo_station_seed s
cross join lateral generate_series(1, s.ac_ports) as g
where s.ac_ports > 0
on conflict (id) do update set
    "stationId"     = excluded."stationId",
    "portNumber"    = excluded."portNumber",
    "connectorType" = excluded."connectorType",
    "powerKw"       = excluded."powerKw",
    "isDc"          = excluded."isDc",
    status          = excluded.status;

insert into public.charger_ports (
    id, "stationId", "portNumber", "connectorType", "powerKw", "isDc", status
)
select
    s.id || '_dc' || g as id,
    s.id as station_id,
    'DC-' || g as port_number,
    'CCS_2_DC' as connector_type,
    s.dc_kw as power_kw,
    true as is_dc,
    'AVAILABLE' as status
from _amperly_demo_station_seed s
cross join lateral generate_series(1, s.dc_ports) as g
where s.dc_ports > 0
on conflict (id) do update set
    "stationId"     = excluded."stationId",
    "portNumber"    = excluded."portNumber",
    "connectorType" = excluded."connectorType",
    "powerKw"       = excluded."powerKw",
    "isDc"          = excluded."isDc",
    status          = excluded.status;


-- ----------------------------------------------------------------------------
-- 5. Opening hours: one window per port per day (1..7 = Sun..Sat, matching
--    java.util.Calendar.DAY_OF_WEEK, which AvailabilityEngine reads).
--    24-hour stations use 0..1440 minutes.
-- ----------------------------------------------------------------------------
insert into public.availability_schedules (
    id, "stationId", "portId", "dayOfWeek", "openMinutes", "closeMinutes",
    "isBlocked", "blockReason", "updatedAtMs"
)
select
    p.id || '_d' || d as id,
    p."stationId" as station_id,
    p.id as port_id,
    d as day_of_week,
    s.open_minutes,
    s.close_minutes,
    false as is_blocked,
    null as block_reason,
    (extract(epoch from now()) * 1000)::bigint as updated_at_ms
from public.charger_ports p
join _amperly_demo_station_seed s on s.id = p."stationId"
cross join generate_series(1, 7) as d
on conflict (id) do update set
    "stationId"     = excluded."stationId",
    "portId"        = excluded."portId",
    "dayOfWeek"     = excluded."dayOfWeek",
    "openMinutes"   = excluded."openMinutes",
    "closeMinutes"  = excluded."closeMinutes",
    "isBlocked"     = excluded."isBlocked",
    "blockReason"   = excluded."blockReason",
    "updatedAtMs"   = excluded."updatedAtMs";


-- ----------------------------------------------------------------------------
-- 6. Verify. This is what the SQL Editor shows after the run: every row must
--    be PENDING, not paused, unverified, and have at least one port.
-- ----------------------------------------------------------------------------
select
    s.id,
    s.name,
    s."hostId" as host_id,
    s."hostName" as host_name,
    s."locationType" as location_type,
    s."approvalStatus" as approval_status,
    s."isPaused" as is_paused,
    s."isVerified" as is_verified,
    s."portCount" as port_count,
    s."maxPowerKw" as max_power_kw
from public.charger_stations s
where s.id like 'demo_%'
order by s.id;

-- ----------------------------------------------------------------------------
-- 7. Clean up the staging table. The demo rows stay in the public tables.
-- ----------------------------------------------------------------------------
drop table if exists _amperly_demo_station_seed;
