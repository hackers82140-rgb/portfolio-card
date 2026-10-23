# Link Drive: sign-in and private cloud data

Link Drive uses Supabase Auth for account creation and sign-in. Each account's links are stored in a private database row protected by row-level security. The app also saves a browser-local copy for the signed-in account.

## Current project configuration

The HTML currently has a Supabase project URL and public publishable key configured. The URL must be the project root, such as `https://your-project.supabase.co`; do not add `/rest/v1/` or `/auth/v1/`. The publishable/anon key is intended for browser use. Never put a `service_role` or secret key in the HTML.

## Setup cloud sync

1. Open the Supabase project that matches the URL configured in `create_Link_Drive.html`.
2. In the Supabase **SQL Editor**, run the full [supabase_setup.sql](./supabase_setup.sql) script. It creates `public.linkdrive_user_data`, grants database access only to authenticated users, and restricts each user to their own row. If the old shared table exists, the script removes its public access policies.
3. In SQL Editor, verify the table exists:

   ```sql
   select to_regclass('public.linkdrive_user_data');
   ```

   The result should be `public.linkdrive_user_data`. If it is `null`, the setup was not run in the correct project or did not complete.
4. If the API still reports that the table is missing, check that the SQL Editor and `CLOUD_URL` refer to the same project, run the SQL script again, and wait briefly for the API schema cache to refresh.
5. Serve the page using HTTP/HTTPS, not by opening the HTML as `file:///`. In VS Code, use the **Live Server** extension and choose **Open with Live Server** for `create_Link_Drive.html`. Add that local origin (for example `http://127.0.0.1:5500`) and your deployed website URL to Supabase **Authentication → URL Configuration**.
6. Open the page, create an account if needed, then sign in. Once the table is ready, the footer should show **Private cloud · synced**.

## Email confirmation

To disable confirmation for new accounts, open Supabase **Authentication → Sign In / Providers → Email** (the dashboard label can vary), turn off **Confirm email**, and save. This is a Supabase project setting, not an HTML setting. Accounts created while confirmation was enabled may still need to be confirmed from **Authentication → Users** before they can sign in.

## What happens if the table is missing

Authentication can still succeed when the database table is missing. The app then opens the drive in local-only mode and saves changes in that browser for the signed-in account; cloud sync remains unavailable until the SQL setup is completed. This local copy does not sync to other devices.

## Backups and retention

- Use **Backup and restore** to export a JSON backup before changing projects or deploying.
- Existing browser-local or old shared-library data is not automatically merged into the new account. Restore a backup after signing in if needed.
- Supabase free-plan limits and availability can change. Neither a free tier nor a database guarantees lifetime retention; keep independent backups.
- The app stores link URLs and notes, not the linked websites or files. Those resources may stop working independently.
