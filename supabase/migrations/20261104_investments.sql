-- Strategy: planned purchases and upgrades ("Investitionen") and the current setup.
-- Additive only. Investments are plans, not expenses: nothing here touches the finance figures.
-- The link to finance is podcast_fin_bookings.investment_id (set only by a manual takeover),
-- the link to tasks is podcast_todos.investment_id. Category = setup area for a later upgrade board.
create table if not exists public.podcast_investment_categories (
  id uuid primary key default gen_random_uuid(),
  name text not null check (length(trim(name)) > 0) unique,
  key text unique,                       -- stable key for built-in categories (e.g. audio)
  sort integer not null default 100,
  archived boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.podcast_investments (
  id uuid primary key default gen_random_uuid(),
  title text not null check (length(trim(title)) > 0),
  category_id uuid references public.podcast_investment_categories(id) on delete set null,
  description text,
  price_cents bigint check (price_cents is null or (price_cents >= 0 and price_cents <= 100000000)),  -- estimate; null = not known yet
  priority text not null default 'medium' check (priority in ('high','medium','low')),
  status text not null default 'idea' check (status in ('idea','planned','watch','ready','bought')),
  target_year integer check (target_year is null or target_year between 2020 and 2100),
  target_quarter integer check (target_quarter is null or target_quarter between 1 and 4),
  note text,
  current_solution text,
  target_solution text,
  purchase_condition text,
  purchased_at date,
  created_by text, updated_by text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.podcast_setup_items (
  id uuid primary key default gen_random_uuid(),
  category_id uuid references public.podcast_investment_categories(id) on delete set null,
  title text not null check (length(trim(title)) > 0),
  sort integer not null default 100,
  created_at timestamptz not null default now()
);

alter table public.podcast_fin_bookings add column if not exists investment_id uuid references public.podcast_investments(id) on delete set null;
-- An investment can be taken over into finance only once.
create unique index if not exists podcast_fin_bookings_investment_uq on public.podcast_fin_bookings (investment_id) where investment_id is not null;
alter table public.podcast_todos add column if not exists investment_id uuid references public.podcast_investments(id) on delete set null;

do $$
declare t text;
begin
  foreach t in array array['podcast_investment_categories','podcast_investments','podcast_setup_items']
  loop
    execute format('alter table public.%I enable row level security', t);
    execute format('create policy %I on public.%I for all to anon using (true) with check (true)', 'anon_all_' || replace(t, 'podcast_', ''), t);
    execute format('create policy %I on public.%I for all to authenticated using (public.is_app_user()) with check (public.is_app_user())', 'members_all_' || replace(t, 'podcast_', ''), t);
    execute format('alter publication supabase_realtime add table public.%I', t);
  end loop;
end $$;

insert into public.podcast_investment_categories (name, key, sort) values
  ('Audio', 'audio', 10),
  ('Licht', 'light', 20),
  ('Kamera', 'camera', 30),
  ('Set / Hintergrund', 'set', 40),
  ('Akustik', 'acoustics', 50),
  ('Schnitt / Workflow', 'workflow', 60),
  ('Sonstiges', 'other', 90)
on conflict (key) do nothing;

-- Start data, only into empty tables. Prices stay open until someone has researched them.
do $$
begin
  if not exists (select 1 from public.podcast_investments) then
    insert into public.podcast_investments (title, category_id, description, current_solution, purchase_condition)
    select v.title, c.id, v.description, v.current_solution, v.purchase_condition
    from (values
      ('Lightbox / besseres Licht-Setup', 'light', 'Gleichmäßigeres, weicheres Licht und ein hochwertigeres Videobild.', 'Einfaches Ringlicht mit Handyhalterung', null),
      ('Bessere Mikrofone', 'audio', 'Klarerer Klang und weniger Raumanteil in den Aufnahmen.', 'Rode NT-USB+', null),
      ('Audio-Interface', 'audio', 'Mehr Kontrolle über die Aufnahme und Grundlage für XLR-Mikrofone.', null, null),
      ('Akustikverbesserung', 'acoustics', 'Weniger Hall im Raum und weniger Nachbearbeitung beim Ton.', null, null),
      ('Besseres Hintergrund- / Set-Design', 'set', 'Wiedererkennbarer, hochwertigerer Look in Video und Clips.', null, null),
      ('Externer Langfolgenschnitt', 'workflow', 'Entlastet bei der Produktion und schafft Zeit für Inhalte und Gäste.', null, 'ab 300 € Monatsumsatz')
    ) as v(title, cat_key, description, current_solution, purchase_condition)
    join public.podcast_investment_categories c on c.key = v.cat_key;
  end if;
  if not exists (select 1 from public.podcast_setup_items) then
    insert into public.podcast_setup_items (category_id, title, sort)
    select c.id, v.title, v.sort
    from (values
      ('Rode NT-USB+', 'audio', 10),
      ('Je ein Mikrofonständer am Schreibtisch', 'audio', 20),
      ('Einfaches Ringlicht mit Handyhalterung', 'light', 30)
    ) as v(title, cat_key, sort)
    join public.podcast_investment_categories c on c.key = v.cat_key;
  end if;
end $$;
