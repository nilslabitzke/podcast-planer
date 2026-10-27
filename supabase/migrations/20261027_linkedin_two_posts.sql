-- LinkedIn: only 2 posts per episode, on the 1st and 2nd Tuesday after release at 07:45.
-- Applied: 2026-10-27. Backups before: backup-2026-10-27.json (bucket) and
-- PodcastBackups/posts-2026-10-27-pre-linkedin2.json (local).
-- Only upcoming episodes (release >= 26.10.2026); past episodes keep their 5 posts.
-- Only empty, unpublished template posts are removed.

begin;
with eps as (select id from podcast_episodes where to_date(date, 'DD.MM.YYYY') >= date '2026-10-26')
delete from podcast_posts p using eps
where p.episode_id = eps.id and p.format = 'linkedin' and p.template_key in ('linkedin-2', 'linkedin-3', 'linkedin-5')
  and p.status <> 'published' and coalesce(p.description, '') = '' and p.media_link is null and p.publish_link is null;

-- The former post 4 already sits on the 2nd Tuesday (release + 8) at 07:45.
update podcast_posts p set template_key = 'linkedin-2', title = 'LinkedIn-Beitrag 2', time = '07:45'
from podcast_episodes e
where e.id = p.episode_id and to_date(e.date, 'DD.MM.YYYY') >= date '2026-10-26' and p.template_key = 'linkedin-4'
  and not exists (select 1 from podcast_posts q where q.episode_id = p.episode_id and q.template_key = 'linkedin-2');
commit;
