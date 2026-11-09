-- Personal settings per signed-in Supabase Auth user (first use: dashboard layout).
-- Additive only; no shared podcast data is stored here. Only the owner can read or change a row,
-- and only while listed in app_users. No anon access – before sign-in the app shows the default dashboard.
create table if not exists public.podcast_user_preferences (
  user_id uuid primary key references auth.users(id) on delete cascade,
  dashboard_layout jsonb not null default '{}'::jsonb
    check (jsonb_typeof(dashboard_layout) = 'object' and pg_column_size(dashboard_layout) < 32768),
  updated_at timestamptz not null default now()
);

alter table public.podcast_user_preferences enable row level security;
revoke all on public.podcast_user_preferences from anon;

create policy own_select_user_preferences on public.podcast_user_preferences
  for select to authenticated using (user_id = (select auth.uid()) and public.is_app_user());
create policy own_insert_user_preferences on public.podcast_user_preferences
  for insert to authenticated with check (user_id = (select auth.uid()) and public.is_app_user());
create policy own_update_user_preferences on public.podcast_user_preferences
  for update to authenticated using (user_id = (select auth.uid()) and public.is_app_user())
  with check (user_id = (select auth.uid()) and public.is_app_user());
create policy own_delete_user_preferences on public.podcast_user_preferences
  for delete to authenticated using (user_id = (select auth.uid()) and public.is_app_user());
