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
