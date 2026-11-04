-- Social-media posts: who ticked "published". Responsibility stays podcast_posts.assignee (reused).
-- Additive; existing posts keep published_by = null ("not recorded"), nothing is back-filled.
alter table public.podcast_posts add column if not exists published_by text;

-- published_at is now set only on the transition to 'published'. Before, every update of a published
-- post without a timestamp (such as assigning it) would have invented "now" as its publication time.
create or replace function public.podcast_posts_touch() returns trigger
language plpgsql set search_path = '' as $$
begin
  new.updated_at := now();
  if new.status = 'published' and old.status is distinct from 'published' and new.published_at is null then new.published_at := now(); end if;
  if new.status <> 'published' then new.published_at := null; new.published_by := null; end if;
  return new;
end $$;
