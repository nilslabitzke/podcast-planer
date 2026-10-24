-- Phase 3: central task management (additive, backward compatible).
-- Existing to-dos keep all values; status is derived from the existing done flag.
-- Applied: 2026-10-24. Backup before: backup-2026-10-24-pre-phase3.json

create table if not exists public.podcast_task_projects (
  id uuid primary key default gen_random_uuid(),
  name text not null check (length(trim(name)) > 0),
  sort integer not null default 0,
  created_at timestamptz not null default now()
);
alter table public.podcast_task_projects enable row level security;
create policy anon_all_task_projects on public.podcast_task_projects
  for all to anon using (true) with check (true);
create policy members_all_task_projects on public.podcast_task_projects
  for all to authenticated using (public.is_app_user()) with check (public.is_app_user());

insert into public.podcast_task_projects (name, sort) values
  ('Organisation & Business', 1),
  ('Finanzen & Steuern', 2),
  ('Technik & Skills', 3),
  ('Marketing & Wachstum', 4),
  ('Gäste & Networking', 5),
  ('Interne Prozesse', 6);

alter table public.podcast_todos
  add column if not exists description text,
  add column if not exists priority text not null default 'medium' check (priority in ('high','medium','low')),
  add column if not exists due_date date,
  add column if not exists status text check (status in ('open','in_progress','done')),
  add column if not exists project_id uuid references public.podcast_task_projects(id) on delete set null,
  add column if not exists parent_id text references public.podcast_todos(id) on delete cascade,
  add column if not exists updated_at timestamptz not null default now();

update public.podcast_todos set status = case when done then 'done' else 'open' end where status is null;
alter table public.podcast_todos alter column status set default 'open';
alter table public.podcast_todos alter column status set not null;

create index if not exists podcast_todos_parent_idx on public.podcast_todos (parent_id);

alter publication supabase_realtime add table public.podcast_task_projects;

-- Keep done <-> status consistent no matter which client version writes.
create or replace function public.podcast_todos_sync_status() returns trigger
language plpgsql set search_path = '' as $$
begin
  if tg_op = 'INSERT' then
    if new.done and new.status <> 'done' then new.status := 'done';
    elsif new.status = 'done' then new.done := true;
    end if;
  else
    if new.status is distinct from old.status then
      new.done := (new.status = 'done');
    elsif new.done is distinct from old.done then
      new.status := case when new.done then 'done' else 'open' end;
    end if;
    new.updated_at := now();
  end if;
  if new.done and new.done_at is null then new.done_at := now(); end if;
  if not new.done then new.done_at := null; end if;
  return new;
end $$;
create trigger podcast_todos_sync_status before insert or update on public.podcast_todos
  for each row execute function public.podcast_todos_sync_status();
