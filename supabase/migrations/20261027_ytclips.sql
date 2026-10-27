-- YT-Clips: new post format "ytclip" (2 per episode: Sunday week 1 ~10:00, Thursday week 2 ~16:00).
-- Applied: 2026-10-27. Backup before: PodcastBackups/posts-2026-10-27-pre-ytclips.json
-- Additive: widens the format check, adds clips only for upcoming episodes (release >= 26.10.2026).

alter table public.podcast_posts drop constraint if exists podcast_posts_format_check;
alter table public.podcast_posts add constraint podcast_posts_format_check
  check (format in ('reel','carousel','story','linkedin','ytclip','short','community','post','other'));

insert into public.podcast_posts (episode_id, template_key, format, platforms, date, time, title, status)
select e.id, t.tkey, 'ytclip', array['youtube'], to_date(e.date, 'DD.MM.YYYY') + t.off, t.ptime, t.title, 'planned'
from public.podcast_episodes e
cross join (values ('ytclip-1', 6, '10:00', 'YT-Clip 1'), ('ytclip-2', 10, '16:00', 'YT-Clip 2')) as t(tkey, off, ptime, title)
where e.date ~ '^\d{2}\.\d{2}\.\d{4}$' and to_date(e.date, 'DD.MM.YYYY') >= date '2026-10-26'
  and exists (select 1 from public.podcast_posts p where p.episode_id = e.id and p.template_key is not null)
on conflict (episode_id, template_key) do nothing;
