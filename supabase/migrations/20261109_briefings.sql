-- Interview-Briefings: documents created externally with our Claude skill, stored here as Markdown text.
-- One briefing per idea and/or episode (the same row moves along from idea to episode – no copy),
-- immutable versions, shared interview notes, optional private PDF per version.
-- Confidential: members only (no anon policies), private bucket. Additive only.
create table if not exists public.podcast_briefings (
  id uuid primary key default gen_random_uuid(),
  idea_id text references public.podcast_ideas(id) on delete set null,
  episode_id text references public.podcast_episodes(id) on delete set null,
  expert_id uuid references public.podcast_experts(id) on delete set null,
  title text not null check (length(trim(title)) between 1 and 300),
  current_version_id uuid,
  claude_url text check (claude_url is null or claude_url ~* '^https://[^/@\s]+(/\S*)?$'),
  created_by text, created_uid uuid default auth.uid(),
  updated_by text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (idea_id is not null or episode_id is not null)
);
create unique index if not exists podcast_briefings_idea_uq on public.podcast_briefings (idea_id) where idea_id is not null;
create unique index if not exists podcast_briefings_episode_uq on public.podcast_briefings (episode_id) where episode_id is not null;
create index if not exists podcast_briefings_expert_idx on public.podcast_briefings (expert_id);

create table if not exists public.podcast_briefing_versions (
  id uuid primary key default gen_random_uuid(),
  briefing_id uuid not null references public.podcast_briefings(id) on delete restrict,
  version_number integer not null check (version_number >= 1),
  markdown_content text not null check (length(markdown_content) between 1 and 2000000),
  change_note text,
  source text not null default 'file' check (source in ('file', 'paste')),
  file_name text,
  pdf_path text,
  pdf_name text,
  created_by text, created_uid uuid default auth.uid(),
  created_at timestamptz not null default now(),
  unique (briefing_id, version_number)
);
alter table public.podcast_briefings drop constraint if exists podcast_briefings_current_version_fk;
alter table public.podcast_briefings add constraint podcast_briefings_current_version_fk
  foreign key (current_version_id) references public.podcast_briefing_versions(id) on delete set null;

-- Versions are never overwritten: only a missing PDF may be attached afterwards.
create or replace function public.podcast_briefing_version_guard() returns trigger
language plpgsql set search_path = '' as $$
begin
  if new.markdown_content is distinct from old.markdown_content or new.version_number is distinct from old.version_number
     or new.briefing_id is distinct from old.briefing_id or new.created_at is distinct from old.created_at
     or (old.pdf_path is not null and new.pdf_path is distinct from old.pdf_path) then
    raise exception 'Briefing-Versionen sind unveränderlich';
  end if;
  return new;
end $$;
drop trigger if exists podcast_briefing_version_guard on public.podcast_briefing_versions;
create trigger podcast_briefing_version_guard before update on public.podcast_briefing_versions
  for each row execute function public.podcast_briefing_version_guard();

create table if not exists public.podcast_briefing_notes (
  id uuid primary key default gen_random_uuid(),
  briefing_id uuid not null references public.podcast_briefings(id) on delete cascade,
  content text not null check (length(trim(content)) between 1 and 20000),
  author text, author_uid uuid default auth.uid(),
  updated_by text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists podcast_briefing_notes_briefing_idx on public.podcast_briefing_notes (briefing_id);
create index if not exists podcast_briefing_versions_briefing_idx on public.podcast_briefing_versions (briefing_id);

do $$
declare t text;
begin
  foreach t in array array['podcast_briefings','podcast_briefing_versions','podcast_briefing_notes']
  loop
    execute format('alter table public.%I enable row level security', t);
    execute format('revoke all on public.%I from anon', t);
    execute format('create policy %I on public.%I for all to authenticated using (public.is_app_user()) with check (public.is_app_user())', 'members_all_' || replace(t, 'podcast_', ''), t);
    execute format('alter publication supabase_realtime add table public.%I', t);
  end loop;
end $$;

-- PDF attachments: private bucket, members only, PDF only, max. 25 MB.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('briefings', 'briefings', false, 26214400, array['application/pdf'])
on conflict (id) do nothing;
create policy briefings_members_select on storage.objects for select to authenticated using (bucket_id = 'briefings' and public.is_app_user());
create policy briefings_members_insert on storage.objects for insert to authenticated with check (bucket_id = 'briefings' and public.is_app_user());
