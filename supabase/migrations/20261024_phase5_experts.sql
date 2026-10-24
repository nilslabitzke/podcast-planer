-- Phase 5: expert CRM (additive). Existing guest texts in ideas/episodes are untouched.
-- Applied: 2026-10-24. Backup before: backup-2026-10-24-pre-phase5.json

create table if not exists public.podcast_experts (
  id uuid primary key default gen_random_uuid(),
  name text not null check (length(trim(name)) > 0),
  title text,                 -- akademischer Titel
  field text,                 -- Fachgebiet
  specialization text,
  institution text,           -- Klinik / Universität
  email text,
  website text,
  social text,
  drive_link text,
  notes text,
  status text not null default 'wish' check (status in ('wish','research','prepare','request_sent','reply',
    'confirmed','scheduled','recorded','published','declined','postponed')),
  status_changed_at timestamptz not null default now(),
  owner text check (owner in ('leo','nils')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.podcast_expert_contacts (
  id uuid primary key default gen_random_uuid(),
  expert_id uuid not null references public.podcast_experts(id) on delete cascade,
  date date not null default current_date,
  channel text not null default 'email',
  summary text not null default '',
  responsible text check (responsible in ('leo','nils')),
  next_follow_up date,
  created_at timestamptz not null default now()
);
create index if not exists podcast_expert_contacts_expert_idx on public.podcast_expert_contacts (expert_id, date desc);

create table if not exists public.podcast_expert_ideas (
  expert_id uuid not null references public.podcast_experts(id) on delete cascade,
  idea_id text not null references public.podcast_ideas(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (expert_id, idea_id)
);
create table if not exists public.podcast_expert_episodes (
  expert_id uuid not null references public.podcast_experts(id) on delete cascade,
  episode_id text not null references public.podcast_episodes(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (expert_id, episode_id)
);

create table if not exists public.podcast_settings (
  key text primary key,
  value jsonb not null,
  updated_at timestamptz not null default now()
);
insert into public.podcast_settings (key, value) values ('expert_follow_up_days', '10'::jsonb)
  on conflict (key) do nothing;

-- status_changed_at is maintained server-side, so the "no reply since" clock is reliable.
create or replace function public.podcast_experts_touch() returns trigger
language plpgsql set search_path = '' as $$
begin
  if new.status is distinct from old.status then new.status_changed_at := now(); end if;
  return new;
end $$;
create trigger podcast_experts_touch before update on public.podcast_experts
  for each row execute function public.podcast_experts_touch();

do $$
declare t text;
begin
  foreach t in array array['podcast_experts','podcast_expert_contacts','podcast_expert_ideas','podcast_expert_episodes','podcast_settings']
  loop
    execute format('alter table public.%I enable row level security', t);
    execute format('create policy %I on public.%I for all to anon using (true) with check (true)', 'anon_all_' || replace(t, 'podcast_', ''), t);
    execute format('create policy %I on public.%I for all to authenticated using (public.is_app_user()) with check (public.is_app_user())', 'members_all_' || replace(t, 'podcast_', ''), t);
  end loop;
end $$;

alter publication supabase_realtime add table public.podcast_experts, public.podcast_expert_contacts,
  public.podcast_expert_ideas, public.podcast_expert_episodes, public.podcast_settings;
