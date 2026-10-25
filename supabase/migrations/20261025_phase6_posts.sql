-- Phase 6: flexible social-media calendar (additive).
-- podcast_episodes.content_plan is left untouched (kept as historical source).
-- Applied: 2026-10-25. Backup before: backup-2026-10-25-pre-phase6.json

create table if not exists public.podcast_posts (
  id uuid primary key default gen_random_uuid(),
  episode_id text references public.podcast_episodes(id) on delete cascade,
  template_key text,                 -- e.g. reel-3, carousel-2, linkedin-5 (posts from the standard template)
  format text not null default 'post' check (format in ('reel','carousel','story','linkedin','short','community','post','other')),
  platforms text[] not null default '{}',
  date date not null,
  time text,                         -- HH:MM, Europe/Berlin
  assignee text check (assignee in ('leo','nils')),
  title text not null default '',
  description text not null default '',
  media_link text,
  publish_link text,
  status text not null default 'planned' check (status in ('planned','in_progress','scheduled','published')),
  published_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (episode_id, template_key)  -- one post per template slot and episode: no duplicates
);
create index if not exists podcast_posts_date_idx on public.podcast_posts (date);

create or replace function public.podcast_posts_touch() returns trigger
language plpgsql set search_path = '' as $$
begin
  new.updated_at := now();
  if new.status = 'published' and new.published_at is null then new.published_at := now(); end if;
  if new.status <> 'published' then new.published_at := null; end if;
  return new;
end $$;
create trigger podcast_posts_touch before update on public.podcast_posts
  for each row execute function public.podcast_posts_touch();

alter table public.podcast_posts enable row level security;
create policy anon_all_posts on public.podcast_posts for all to anon using (true) with check (true);
create policy members_all_posts on public.podcast_posts for all to authenticated using (public.is_app_user()) with check (public.is_app_user());
alter publication supabase_realtime add table public.podcast_posts;

-- Standard template (8 reels, 3 carousels, 5 LinkedIn posts over 14 days from release),
-- identical to the former fixed CONTENT_CAL_TEMPLATE. idx = position on that day in the old plan.
create temporary table tpl (off int, idx int, tkey text, format text, platforms text[], ptime text, title text) on commit drop;
insert into tpl values
  (0, 0, 'carousel-1', 'carousel', '{ig_carousel}', '07:00', 'Karussell 1'),
  (0, 1, 'reel-1', 'reel', '{ig_reels,tiktok,yt_shorts}', '18:30', 'Reel 1'),
  (1, 0, 'linkedin-1', 'linkedin', '{linkedin}', '07:45', 'LinkedIn-Beitrag 1'),
  (1, 1, 'carousel-2', 'carousel', '{ig_carousel}', '18:00', 'Karussell 2'),
  (2, 0, 'reel-2', 'reel', '{ig_reels,tiktok,yt_shorts}', '18:30', 'Reel 2'),
  (3, 0, 'linkedin-2', 'linkedin', '{linkedin}', '07:45', 'LinkedIn-Beitrag 2'),
  (3, 1, 'reel-3', 'reel', '{ig_reels,tiktok,yt_shorts}', '18:30', 'Reel 3'),
  (4, 0, 'reel-4', 'reel', '{ig_reels,tiktok,yt_shorts}', '18:30', 'Reel 4'),
  (5, 0, 'linkedin-3', 'linkedin', '{linkedin}', '09:00', 'LinkedIn-Beitrag 3'),
  (7, 0, 'reel-5', 'reel', '{ig_reels,tiktok,yt_shorts}', '18:30', 'Reel 5'),
  (8, 0, 'linkedin-4', 'linkedin', '{linkedin}', '07:45', 'LinkedIn-Beitrag 4'),
  (8, 1, 'carousel-3', 'carousel', '{ig_carousel}', '18:00', 'Karussell 3'),
  (9, 0, 'reel-6', 'reel', '{ig_reels,tiktok,yt_shorts}', '18:30', 'Reel 6'),
  (10, 0, 'linkedin-5', 'linkedin', '{linkedin}', '07:45', 'LinkedIn-Beitrag 5'),
  (10, 1, 'reel-7', 'reel', '{ig_reels,tiktok,yt_shorts}', '18:30', 'Reel 7'),
  (11, 0, 'reel-8', 'reel', '{ig_reels,tiktok,yt_shorts}', '18:30', 'Reel 8');

-- Posts for every episode that has calendar data or whose content window is still open/upcoming.
-- Ticks and N/L assignments are carried over 1:1 from content_plan.
insert into public.podcast_posts (episode_id, template_key, format, platforms, date, time, title, status, assignee)
select e.id, t.tkey, t.format, t.platforms, to_date(e.date, 'DD.MM.YYYY') + t.off, t.ptime, t.title,
  case when (jsonb_typeof(v.val) = 'boolean' and v.val = 'true'::jsonb)
         or (jsonb_typeof(v.val) = 'object' and v.val->>'done' = 'true') then 'published' else 'planned' end,
  case when jsonb_typeof(v.val) = 'object' then case v.val->>'assignee' when 'N' then 'nils' when 'L' then 'leo' end end
from public.podcast_episodes e
cross join tpl t
cross join lateral (select e.content_plan -> to_char(to_date(e.date, 'DD.MM.YYYY') + t.off, 'DD.MM.YYYY') -> t.idx::text as val) v
where e.content_plan <> '{}'::jsonb or to_date(e.date, 'DD.MM.YYYY') >= current_date - 13
on conflict (episode_id, template_key) do nothing;
