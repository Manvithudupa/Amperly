-- ============================================================================
--  Amperly — link seeded users to Supabase Auth accounts
-- ============================================================================
--  Run this AFTER:
--    1. schema.sql
--    2. pilot_seed.sql
--    3. creating the four accounts in Dashboard -> Authentication -> Users
--       (use the same email addresses as the seed, and tick "Auto Confirm User")
--
--  The app identifies the signed-in user by matching auth.uid() to
--  users."authUserId". Until that column is filled in, a signed-in user is
--  anonymous as far as Row Level Security is concerned and sees nothing.
--
--  Safe to re-run.
-- ============================================================================

update public.users u
   set "authUserId" = a.id
  from auth.users a
 where lower(a.email) = lower(u.email)
   and u."authUserId" is distinct from a.id;

-- ---------------------------------------------------------------------------
--  Check the result. Every seeded user should now show an authUserId except
--  any you have not created an Auth account for yet.
-- ---------------------------------------------------------------------------
select u.id,
       u.email,
       u.role,
       u."authUserId" is not null as linked
from public.users u
order by u.id;

-- ---------------------------------------------------------------------------
--  If you would rather link by hand, use the user's UUID from
--  Dashboard -> Authentication -> Users:
--
--    update public.users
--       set "authUserId" = '<paste-auth-user-uuid-here>'
--     where id = 'user_student_1';
-- ---------------------------------------------------------------------------
