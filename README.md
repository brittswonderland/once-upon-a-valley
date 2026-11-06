# Once Upon a Valley 💜
**Private source-code foundation**, not a complete game database or public release.

## Project layout
- `apps/mobile` — Expo React Native starter for iPhone and Android, with a local manual furniture/clothing list and basic screens.
- `apps/admin` — Vite React private developer dashboard with email/password sign-in and draft/publish catalog entries.
- `supabase/migrations/0001_foundation.sql` — PostgreSQL catalog, profiles, ownership, chests, recipes, DreamSnaps, admin roles, RLS and private photo bucket.
- `docs/ADMIN_SETUP.md` — create your administrator account.

## Running
Install Node.js and Git on a computer. In this folder:
```sh
npm install
npm run mobile
```
Use Expo Go to test on iPhone/Android. Native screenshot sharing will require later development and potentially custom builds.

For the dashboard, create a Supabase project and follow `docs/ADMIN_SETUP.md`, then:
```sh
npm run admin
```
Open the local URL printed by Vite. `apps/mobile/.env.example` and `apps/admin/.env.example` show the required public client settings; copy to `.env` and keep secrets out of Git.

## Own the code
Create a **private** repository in your own GitHub account. From the extracted project:
```sh
git init
git add .
git commit -m "Initial private Once Upon a Valley foundation"
git branch -M main
git remote add origin YOUR_PRIVATE_REPOSITORY_URL
git push -u origin main
```
Create the Supabase project in your own account. You can edit catalog entries through the dashboard after configuring it; code changes happen in Git and may require app store updates.

## Status and limitations
No verified full-game item catalog, Snap & Collect image recognition, batch uploads, cloud photo syncing, production auth in mobile, or deployed service yet. The mobile starter saves manual items only on the current device. Existing HTML prototype localStorage is not automatically migrated. The dashboard is functional starter source but needs your real Supabase credentials and end-to-end testing. Do not distribute as a complete app.
