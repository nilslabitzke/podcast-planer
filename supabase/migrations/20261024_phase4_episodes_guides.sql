-- Phase 4: episode manager & SOP guides (additive, backward compatible).
-- Applied: 2026-10-24. Backup before: backup-2026-10-24-pre-phase4.json

-- Episode fields: production status (independent of the checklist), guest, links, approvals.
alter table public.podcast_episodes
  add column if not exists status text check (status in
    ('planned','guest_requested','recording_scheduled','recorded','editing','ready','published')),
  add column if not exists guest text,
  add column if not exists links jsonb not null default '{}'::jsonb,
  add column if not exists approvals jsonb not null default '{}'::jsonb;

-- Initial status for existing episodes, derived once from existing data:
-- release date passed -> published; edited -> ready; recorded -> recorded;
-- recording date set -> recording_scheduled; otherwise planned.
update public.podcast_episodes set status = case
    when to_date(date, 'DD.MM.YYYY') < current_date then 'published'
    when (tasks->'schnitt'->>'done')::boolean then 'ready'
    when (tasks->'aufnahme'->>'done')::boolean then 'recorded'
    when recording_date is not null then 'recording_scheduled'
    else 'planned' end
  where status is null;
alter table public.podcast_episodes alter column status set default 'planned';

-- Guides: working copy (draft) + latest released version number.
create table if not exists public.podcast_guides (
  id uuid primary key default gen_random_uuid(),
  title text not null check (length(trim(title)) > 0),
  category text,
  instructions text not null default '',
  checklist jsonb not null default '[]'::jsonb,   -- [{id, text, required}]
  step_ids text[] not null default '{}',           -- linked production steps
  version integer not null default 0,              -- 0 = never released
  released_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
-- Immutable snapshots of every released version.
create table if not exists public.podcast_guide_versions (
  id uuid primary key default gen_random_uuid(),
  guide_id uuid not null references public.podcast_guides(id) on delete cascade,
  version integer not null,
  title text not null,
  instructions text not null default '',
  checklist jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now(),
  unique (guide_id, version)
);

alter table public.podcast_guides enable row level security;
alter table public.podcast_guide_versions enable row level security;
create policy anon_all_guides on public.podcast_guides for all to anon using (true) with check (true);
create policy members_all_guides on public.podcast_guides for all to authenticated using (public.is_app_user()) with check (public.is_app_user());
create policy anon_all_guide_versions on public.podcast_guide_versions for all to anon using (true) with check (true);
create policy members_all_guide_versions on public.podcast_guide_versions for all to authenticated using (public.is_app_user()) with check (public.is_app_user());

alter publication supabase_realtime add table public.podcast_guides;

-- Starter guides from the brief as unreleased drafts (empty checklists, so they
-- gate nothing until content is written and released).
insert into public.podcast_guides (title, category, step_ids) values
  ('Interviewfragen vorbereiten', 'Vorbereitung', '{fragenerstellung}'),
  ('Riverside-Aufnahme durchführen', 'Aufnahme', '{aufnahme}'),
  ('Hook für die Folge erstellen', 'Postproduktion', '{hook}'),
  ('Folge schneiden und exportieren', 'Postproduktion', '{schnitt}'),
  ('Spotify-Upload vorbereiten', 'Veröffentlichung', '{}'),
  ('YouTube-Upload vorbereiten', 'Veröffentlichung', '{}'),
  ('Reel schneiden', 'Social Media', '{reels_download}'),
  ('Reel veröffentlichen', 'Social Media', '{sm1_reels,sm2_reels}'),
  ('LinkedIn-Beitrag veröffentlichen', 'Social Media', '{li_beitraege}');
