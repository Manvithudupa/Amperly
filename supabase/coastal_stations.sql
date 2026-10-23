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
