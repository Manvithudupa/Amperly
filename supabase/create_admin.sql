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
