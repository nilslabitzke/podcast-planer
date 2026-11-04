-- Strategy > Investitionen, Phase 2 (Studio-Upgrade). Additive; uses the same investment rows as Phase 1.
-- studio_area: optional assignment to a studio component (null = derived from the category).
-- planned_next: selection of "Mein nächstes Setup planen", shared between Nils and Leo. Planning only.
-- Status 'in_use' separates "bought" from "actually in use".
alter table public.podcast_investments add column if not exists studio_area text;
alter table public.podcast_investments add column if not exists planned_next boolean not null default false;
alter table public.podcast_setup_items add column if not exists studio_area text;

alter table public.podcast_investments drop constraint if exists podcast_investments_status_check;
alter table public.podcast_investments add constraint podcast_investments_status_check
  check (status in ('idea','planned','watch','ready','bought','in_use'));

-- Start values for the two components a category alone cannot tell apart. Existing assignments stay.
update public.podcast_setup_items set studio_area = 'stand' where studio_area is null and title ilike '%mikrofonständer%';
update public.podcast_investments set studio_area = 'interface' where studio_area is null and title = 'Audio-Interface';
