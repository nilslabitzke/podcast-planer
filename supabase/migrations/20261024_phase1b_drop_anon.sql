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
drop policy if exists anon_all_task_projects on public.podcast_task_projects;  -- added in phase 3
drop policy if exists anon_all_guides         on public.podcast_guides;          -- added in phase 4
drop policy if exists anon_all_guide_versions on public.podcast_guide_versions;  -- added in phase 4
drop policy if exists anon_all_experts         on public.podcast_experts;          -- added in phase 5
drop policy if exists anon_all_expert_contacts on public.podcast_expert_contacts;  -- added in phase 5
drop policy if exists anon_all_expert_ideas    on public.podcast_expert_ideas;     -- added in phase 5
drop policy if exists anon_all_expert_episodes on public.podcast_expert_episodes;  -- added in phase 5
drop policy if exists anon_all_settings        on public.podcast_settings;         -- added in phase 5
