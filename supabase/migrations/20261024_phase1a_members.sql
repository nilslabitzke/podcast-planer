-- Phase 1a: login for Nils & Leo (additive, non-breaking).
-- Adds an allowlist and member policies next to the existing anon policies,
-- so the app keeps working while both switch to logging in.
-- Applied: 2026-10-24.

create table if not exists public.app_users (
  email text primary key check (email = lower(email)),
  name text not null,
  created_at timestamptz not null default now()
);
alter table public.app_users enable row level security;

create or replace function public.is_app_user() returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.app_users
    where email = lower(coalesce(auth.jwt() ->> 'email', ''))
  );
$$;
revoke all on function public.is_app_user() from public, anon;
grant execute on function public.is_app_user() to authenticated;

create policy app_users_read on public.app_users
  for select to authenticated using (public.is_app_user());

do $$
declare t text;
begin
  foreach t in array array['podcast_episodes','podcast_ideas','podcast_goals','podcast_improvements',
                           'podcast_prompts','podcast_todos','podcast_expenses','podcast_income','podcast_settlements']
  loop
    execute format(
      'create policy %I on public.%I for all to authenticated using (public.is_app_user()) with check (public.is_app_user())',
      'members_all_' || replace(t, 'podcast_', ''), t);
  end loop;
end $$;

alter publication supabase_realtime add table public.podcast_episodes, public.podcast_ideas;

insert into public.app_users (email, name) values ('nilslabitzke@gmx.de', 'Nils')
  on conflict (email) do nothing;
-- Leo: insert into public.app_users (email, name) values ('<leo-email>', 'Leo');
