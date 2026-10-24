-- Phase 1b: close anonymous access. NOT YET APPLIED.
-- Run only after Nils AND Leo have logged in successfully with Phase 1a,
-- together with the frontend switch AUTH_REQUIRED = true.
-- Before running: trigger a fresh backup (functions/v1/backup) and verify it.
-- Rollback: re-create the anon policies, e.g.
--   create policy anon_all_episodes on public.podcast_episodes for all to anon using (true) with check (true);

drop policy if exists anon_all_episodes     on public.podcast_episodes;
drop policy if exists anon_all_ideas        on public.podcast_ideas;
drop policy if exists anon_all_goals        on public.podcast_goals;
drop policy if exists anon_all_improvements on public.podcast_improvements;
drop policy if exists anon_all_prompts      on public.podcast_prompts;
drop policy if exists anon_all_todos        on public.podcast_todos;
drop policy if exists anon_all_expenses     on public.podcast_expenses;
drop policy if exists anon_all_income       on public.podcast_income;
drop policy if exists anon_all_settlements  on public.podcast_settlements;
