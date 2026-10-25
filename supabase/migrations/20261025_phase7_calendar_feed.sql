-- Phase 7: manual podcast events + revocable ICS subscription links (additive).
-- Applied: 2026-10-25. Backup before: backup-2026-10-25-pre-phase7.json

create table if not exists public.podcast_events (
  id uuid primary key default gen_random_uuid(),
  title text not null check (length(trim(title)) > 0),
  date date not null,
  all_day boolean not null default false,
  start_time text,          -- HH:MM, Europe/Berlin
  end_time text,            -- HH:MM, Europe/Berlin
  location text,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- One row per subscription link. The token is the only secret; revoking sets revoked_at.
create table if not exists public.podcast_calendar_feeds (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  token text not null unique check (length(token) >= 32),
  options jsonb not null default '{"recordings":true,"releases":true,"deadlines":true,"posts":false,"events":true,"assignee":""}'::jsonb,
  created_at timestamptz not null default now(),
  revoked_at timestamptz,
  last_accessed_at timestamptz
);

create or replace function public.podcast_events_touch() returns trigger
language plpgsql set search_path = '' as $$
begin new.updated_at := now(); return new; end $$;
create trigger podcast_events_touch before update on public.podcast_events
  for each row execute function public.podcast_events_touch();

do $$
declare t text;
begin
  foreach t in array array['podcast_events','podcast_calendar_feeds']
  loop
    execute format('alter table public.%I enable row level security', t);
    execute format('create policy %I on public.%I for all to anon using (true) with check (true)', 'anon_all_' || replace(t, 'podcast_', ''), t);
    execute format('create policy %I on public.%I for all to authenticated using (public.is_app_user()) with check (public.is_app_user())', 'members_all_' || replace(t, 'podcast_', ''), t);
  end loop;
end $$;

alter publication supabase_realtime add table public.podcast_events;
