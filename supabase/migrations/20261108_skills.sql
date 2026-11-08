-- Leitfäden & Skills: documentation of our own Claude skills. Additive only; nothing here runs or
-- changes a skill. Versions and optimizations are separate tables linked by skill_id; skills are
-- archived (status), not deleted, so their history stays.
create table if not exists public.podcast_skills (
  id uuid primary key default gen_random_uuid(),
  name text not null check (length(trim(name)) > 0),
  description text,
  category text not null default 'other' check (category in ('planning','interview','reels','youtube','spotify','blog','community','design','other')),
  version text,
  status text not null default 'idea' check (status in ('idea','dev','active','optimizing','paused','archived')),
  owner text check (owner in ('nils','leo','both')),
  link_url text check (link_url is null or link_url ~* '^https?://'),
  file_path text,
  notes text,
  created_by text, updated_by text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.podcast_skill_versions (
  id uuid primary key default gen_random_uuid(),
  skill_id uuid not null references public.podcast_skills(id) on delete restrict,
  version text not null check (length(trim(version)) > 0),
  released_on date not null default current_date,
  changes text,
  file_path text,
  created_by text,
  created_at timestamptz not null default now(),
  unique (skill_id, version)
);

create table if not exists public.podcast_skill_optimizations (
  id uuid primary key default gen_random_uuid(),
  skill_id uuid not null references public.podcast_skills(id) on delete restrict,
  title text not null check (length(trim(title)) > 0),
  description text,
  priority text not null default 'medium' check (priority in ('high','medium','low')),
  status text not null default 'open' check (status in ('open','in_progress','done')),
  assignee text check (assignee in ('nils','leo')),
  done_on date,
  todo_id text references public.podcast_todos(id) on delete set null,
  created_by text, updated_by text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
-- A general task belongs to at most one optimization.
create unique index if not exists podcast_skill_optimizations_todo_uq on public.podcast_skill_optimizations (todo_id) where todo_id is not null;
create index if not exists podcast_skill_optimizations_skill_idx on public.podcast_skill_optimizations (skill_id);
create index if not exists podcast_skill_versions_skill_idx on public.podcast_skill_versions (skill_id);

-- Status sync between an optimization and its linked task, in both directions. Each side only
-- updates the other when the value differs, so the two triggers stop after one round.
create or replace function public.podcast_skill_opt_to_todo() returns trigger
language plpgsql set search_path = '' as $$
begin
  if new.todo_id is not null and (tg_op = 'INSERT' or new.status is distinct from old.status or new.todo_id is distinct from old.todo_id) then
    update public.podcast_todos
       set status = new.status, done = (new.status = 'done'),
           done_at = case when new.status = 'done' then coalesce(done_at, now()) else null end,
           updated_at = now()
     where id = new.todo_id and status is distinct from new.status;
  end if;
  return new;
end $$;
create trigger podcast_skill_opt_to_todo after insert or update on public.podcast_skill_optimizations
  for each row execute function public.podcast_skill_opt_to_todo();

create or replace function public.podcast_todo_to_skill_opt() returns trigger
language plpgsql set search_path = '' as $$
begin
  if new.status is distinct from old.status and new.status in ('open','in_progress','done') then
    update public.podcast_skill_optimizations
       set status = new.status,
           done_on = case when new.status = 'done' then coalesce(done_on, current_date) else null end,
           updated_at = now()
     where todo_id = new.id and status is distinct from new.status;
  end if;
  return new;
end $$;
create trigger podcast_todo_to_skill_opt after update on public.podcast_todos
  for each row execute function public.podcast_todo_to_skill_opt();

do $$
declare t text;
begin
  foreach t in array array['podcast_skills','podcast_skill_versions','podcast_skill_optimizations']
  loop
    execute format('alter table public.%I enable row level security', t);
    execute format('create policy %I on public.%I for all to anon using (true) with check (true)', 'anon_all_' || replace(t, 'podcast_', ''), t);
    execute format('create policy %I on public.%I for all to authenticated using (public.is_app_user()) with check (public.is_app_user())', 'members_all_' || replace(t, 'podcast_', ''), t);
    execute format('alter publication supabase_realtime add table public.%I', t);
  end loop;
end $$;

-- Skill files: private bucket, members only (like receipts), max. 20 MB.
insert into storage.buckets (id, name, public, file_size_limit) values ('skills', 'skills', false, 20971520) on conflict (id) do nothing;
create policy skills_members_select on storage.objects for select to authenticated using (bucket_id = 'skills' and public.is_app_user());
create policy skills_members_insert on storage.objects for insert to authenticated with check (bucket_id = 'skills' and public.is_app_user());
create policy skills_members_update on storage.objects for update to authenticated using (bucket_id = 'skills' and public.is_app_user());
create policy skills_members_delete on storage.objects for delete to authenticated using (bucket_id = 'skills' and public.is_app_user());

-- Start structure, only into an empty table: suggestions for taking stock, status "Idee",
-- no version, no owner – nothing claims that a skill already exists or is installed.
insert into public.podcast_skills (name, category, description)
select v.name, v.category, 'Vorschlag zur Bestandsaufnahme – Stand, Version und Speicherort noch nicht dokumentiert.'
from (values
  ('Reel-Produktion', 'reels'), ('Reel-Visuals / Effekte', 'design'), ('YouTube-Clips', 'youtube'),
  ('Podcastfolgen-Planung', 'planning'), ('Interviewvorbereitung', 'interview'), ('Kommentarantworten', 'community'),
  ('Spotify-Beschreibungen', 'spotify'), ('SEO-Blogartikel', 'blog')
) as v(name, category)
where not exists (select 1 from public.podcast_skills);
