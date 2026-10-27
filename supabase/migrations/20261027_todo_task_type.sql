-- Aufgabentyp dauerhaft unterscheidbar machen (additive, backward compatible).
-- Applied: 2026-10-27. Backups before: backup-2026-10-27.json (bucket),
-- PodcastBackups/podcast_todos-2026-10-27-pre-tasktype.json (local).
--
-- podcast_todos holds general podcast tasks. A row with episode_id is NOT a general task:
-- it refers to the production step (episode_id, step_id) whose single source of truth is
-- podcast_episodes.tasks. Such rows are kept for history but never listed as tasks
-- (no duplicates of episode tasks).

alter table public.podcast_todos
  add column if not exists episode_id text references public.podcast_episodes(id) on delete set null,
  add column if not exists step_id text;

-- 13 legacy copies "Lernmethoden (26.10.2026): <step>" created by an earlier migration.
-- Unambiguous: one episode with this title and date; step matched by its (old) label.
update public.podcast_todos t set episode_id = e.id, step_id = m.step_id
from public.podcast_episodes e,
  (values ('mig-00','titel_spotify'), ('mig-01','titel_youtube'), ('mig-02','shownotes'), ('mig-03','kapitel'),
          ('mig-04','upload'), ('mig-05','thumbnail_ai'), ('mig-06','cover_canva'), ('mig-07','reels_download'),
          ('mig-08','sm1_karussell'), ('mig-09','sm1_reels'), ('mig-10','sm2_karussell'), ('mig-11','sm2_reels'),
          ('mig-12','li_beitraege')) as m(todo_id, step_id)
where t.id = m.todo_id and e.title = 'Lernmethoden' and e.date = '26.10.2026'
  and t.text like 'Lernmethoden (26.10.2026): %' and t.episode_id is null;
