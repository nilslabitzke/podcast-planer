-- Blue "new task" markers: who created a task, and up to which task each person has seen new ones.
-- Additive only. Existing tasks have no creator and are older than the seed below, so they never count as new.
alter table public.podcast_todos add column if not exists created_by text;
insert into public.podcast_settings (key, value, updated_at) values
  ('tasks_seen_nils', to_jsonb(now()), now()),
  ('tasks_seen_leo',  to_jsonb(now()), now())
on conflict (key) do nothing;
