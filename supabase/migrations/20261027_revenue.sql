-- Einnahmen (Strategie): monthly revenue per source, traceable corrections, month confirmation,
-- revenue goals. Additive only; existing podcast_goals / podcast_improvements are untouched.
-- Applied: 2026-10-27. Backup before: backup-2026-10-27.json (bucket).
--
-- Amounts are stored as integer cents (EUR). A missing entry row = "not entered";
-- a row with 0 = deliberately entered 0 €. Entries are never negative; negative changes
-- only via podcast_revenue_corrections (append-only, reason required).
-- Year totals are never stored – they are always computed from the months.

create table if not exists public.podcast_revenue_entries (
  id uuid primary key default gen_random_uuid(),
  year integer not null check (year between 2020 and 2100),
  month integer not null check (month between 1 and 12),
  source text not null check (source in ('adsense','sponsoring','affiliate')),
  amount_cents bigint not null check (amount_cents >= 0 and amount_cents <= 100000000),
  updated_by text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (year, month, source)          -- one value per month and source: no duplicates
);

create table if not exists public.podcast_revenue_corrections (
  id uuid primary key default gen_random_uuid(),
  year integer not null check (year between 2020 and 2100),
  month integer not null check (month between 1 and 12),
  source text not null check (source in ('adsense','sponsoring','affiliate')),
  amount_cents bigint not null check (amount_cents <> 0 and abs(amount_cents) <= 100000000),
  reason text not null check (length(trim(reason)) > 0),
  created_by text,
  created_at timestamptz not null default now()
);

create table if not exists public.podcast_revenue_months (
  year integer not null check (year between 2020 and 2100),
  month integer not null check (month between 1 and 12),
  confirmed boolean not null default false,
  confirmed_by text,
  confirmed_at timestamptz,
  updated_at timestamptz not null default now(),
  primary key (year, month)
);

create table if not exists public.podcast_revenue_goals (
  id uuid primary key default gen_random_uuid(),
  year integer not null,
  scope text not null check (scope in ('adsense','total')),
  period text not null check (period in ('year','nov_dec')),
  target_cents bigint not null check (target_cents > 0),
  bonus_cents bigint check (bonus_cents is null or bonus_cents >= target_cents),
  note text,
  created_at timestamptz not null default now(),
  unique (year, scope, period)
);

create or replace function public.podcast_revenue_touch() returns trigger
language plpgsql set search_path = '' as $$
begin new.updated_at := now(); return new; end $$;
create trigger podcast_revenue_entries_touch before update on public.podcast_revenue_entries
  for each row execute function public.podcast_revenue_touch();
create trigger podcast_revenue_months_touch before update on public.podcast_revenue_months
  for each row execute function public.podcast_revenue_touch();

-- Corrections are append-only (a wrong correction is reversed by a counter-correction).
create or replace function public.podcast_revenue_corrections_immutable() returns trigger
language plpgsql set search_path = '' as $$
begin raise exception 'Korrekturen sind unveränderlich – bitte eine Gegenkorrektur erfassen.'; end $$;
create trigger podcast_revenue_corrections_immutable before update or delete on public.podcast_revenue_corrections
  for each row execute function public.podcast_revenue_corrections_immutable();

do $$
declare t text;
begin
  foreach t in array array['podcast_revenue_entries','podcast_revenue_corrections','podcast_revenue_months','podcast_revenue_goals']
  loop
    execute format('alter table public.%I enable row level security', t);
    execute format('create policy %I on public.%I for all to anon using (true) with check (true)', 'anon_all_' || replace(t, 'podcast_', ''), t);
    execute format('create policy %I on public.%I for all to authenticated using (public.is_app_user()) with check (public.is_app_user())', 'members_all_' || replace(t, 'podcast_', ''), t);
    execute format('alter publication supabase_realtime add table public.%I', t);
  end loop;
end $$;

-- Goals (idempotent: re-running never duplicates).
insert into public.podcast_revenue_goals (year, scope, period, target_cents, bonus_cents, note) values
  (2026, 'adsense', 'nov_dec', 40000, 60000, 'Summe November + Dezember 2026 (Ø 200 € bzw. 300 € pro Monat). Referenz: Oktober-Spitzenwert ca. 350 € (kein Buchungseintrag).'),
  (2027, 'adsense', 'year', 240000, 348000, 'Referenz: geplante durchschnittliche YouTube-Einnahmen 2026 ca. 165 € pro Monat.'),
  (2028, 'adsense', 'year', 360000, 492000, null),
  (2028, 'total',   'year', 600000, 1200000, 'AdSense + Sponsoring + Affiliate (AdSense nur einmal gezählt).')
on conflict (year, scope, period) do nothing;

-- Outsourcing rule: long-episode editing paid externally once the monthly average reaches 300 €.
insert into public.podcast_settings (key, value) values
  ('revenue_outsourcing', '{"threshold_cents": 30000, "window_months": 3}'::jsonb)
on conflict (key) do nothing;
