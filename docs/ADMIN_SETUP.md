# Admin setup
1. Create a Supabase project in your own account, enable email/password Auth and email confirmation.
2. Run `supabase/migrations/0001_foundation.sql` in Supabase SQL Editor.
3. Create your user in Supabase Authentication > Users; copy its UUID.
4. In SQL Editor run `insert into public.admin_members(user_id) values ('YOUR-USER-UUID');`.
5. Copy `apps/admin/.env.example` to `apps/admin/.env`, set the Supabase URL and public/publishable key.
6. `npm install` then `npm run admin`; sign in with your account.

There is no public admin signup. Do not put service-role/secret keys in browser/mobile code. Admin access is enforced with row-level security. Audit history is written to `catalog_audit`, but audit browsing/rollback UI are future work. Enable MFA on your Supabase and GitHub owner accounts. Verify all security policies before real users join.
