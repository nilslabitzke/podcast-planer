-- Strategie: growth & production goals 2026–2028, real metric measurements, milestones as general to-dos.
-- Additive only. Applied: 2026-10-27. Backup before: backup-2026-10-27.json (bucket).
--
-- • podcast_strategy_goals: one row per year and metric (unique) with target, bonus and an explicit
--   measurement period. Finance goals stay in podcast_revenue_goals (actuals come from Finanzen).
-- • podcast_metric_values: actual measurements entered by hand (follower snapshots with a date,
--   Spotify plays per month). Planned start values / reference values are NOT stored here – they
--   live as text in reference_note and are never shown as confirmed actuals.
-- • Milestones are ordinary general to-dos (podcast_todos.strategy_year / strategy_key), so the
--   done state exists exactly once and is shared by Aufgaben and Strategie.
-- Existing podcast_goals / podcast_improvements stay untouched.

create table if not exists public.podcast_strategy_goals (
  id uuid primary key default gen_random_uuid(),
  year integer not null check (year between 2020 and 2100),
  category text not null check (category in ('reach','performance')),
  metric_key text not null,
  title text not null,
  measure text not null check (measure in ('snapshot','month_avg','month_sum','episodes')),
  period_start date not null,
  period_end date not null,
  period_label text not null,
  target bigint not null check (target > 0),
  bonus bigint check (bonus is null or bonus >= target),
  reference_note text,
  confirmed_note text,
  sort integer not null default 100,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (year, metric_key)
);

create table if not exists public.podcast_metric_values (
  id uuid primary key default gen_random_uuid(),
  metric_key text not null,
  value bigint not null check (value >= 0),
  measured_on date not null,
  period_month text check (period_month ~ '^\d{4}-(0[1-9]|1[0-2])$'),
  note text,
  created_by text,
  created_at timestamptz not null default now(),
  unique (metric_key, period_month)   -- one value per month for monthly metrics (plays)
);
create index if not exists podcast_metric_values_metric_idx on public.podcast_metric_values (metric_key, measured_on);

alter table public.podcast_todos
  add column if not exists strategy_year integer,
  add column if not exists strategy_key text unique;

create or replace function public.podcast_strategy_touch() returns trigger
language plpgsql set search_path = '' as $$
begin new.updated_at := now(); return new; end $$;
create trigger podcast_strategy_goals_touch before update on public.podcast_strategy_goals
  for each row execute function public.podcast_strategy_touch();

do $$
declare t text;
begin
  foreach t in array array['podcast_strategy_goals','podcast_metric_values']
  loop
    execute format('alter table public.%I enable row level security', t);
    execute format('create policy %I on public.%I for all to anon using (true) with check (true)', 'anon_all_' || replace(t, 'podcast_', ''), t);
    execute format('create policy %I on public.%I for all to authenticated using (public.is_app_user()) with check (public.is_app_user())', 'members_all_' || replace(t, 'podcast_', ''), t);
    execute format('alter publication supabase_realtime add table public.%I', t);
  end loop;
end $$;

-- Goals (idempotent).
insert into public.podcast_strategy_goals (year, category, metric_key, title, measure, period_start, period_end, period_label, target, bonus, reference_note, confirmed_note, sort) values
  (2026, 'reach', 'spotify_followers', 'Spotify-Follower', 'snapshot', '2026-01-01', '2026-12-31', 'Stand zum 31.12.2026', 1000, 1200, 'Referenzstand 1.120 (aus dem bisherigen Ziel, ohne Messdatum)', 'Ziel 1.000 laut Vorgabe erreicht', 20),
  (2026, 'reach', 'youtube_subscribers', 'YouTube-Abonnenten', 'snapshot', '2026-01-01', '2026-12-31', 'Stand zum 31.12.2026', 5500, 6500, null, null, 10),
  (2026, 'performance', 'spotify_plays', 'Spotify-Plays pro Monat', 'month_avg', '2026-11-01', '2026-12-31', 'Ø November + Dezember 2026', 3000, 3500, 'Referenz: 3.109 Plays in 28 Tagen (anderer Zeitraum)', null, 10),
  (2026, 'performance', 'episodes', 'Veröffentlichte Folgen bis Jahresende', 'episodes', '2026-10-27', '2026-12-31', 'veröffentlicht 27.10.–31.12.2026', 4, 5, null, null, 20),
  (2027, 'reach', 'youtube_subscribers', 'YouTube-Abonnenten', 'snapshot', '2027-01-01', '2027-12-31', 'Stand zum 31.12.2027', 8000, 9500, 'geplanter Startwert ca. 5.500', null, 10),
  (2027, 'reach', 'spotify_followers', 'Spotify-Follower', 'snapshot', '2027-01-01', '2027-12-31', 'Stand zum 31.12.2027', 1900, 2150, 'geplanter Startwert ca. 1.250', null, 20),
  (2027, 'reach', 'instagram_followers', 'Instagram-Follower', 'snapshot', '2027-01-01', '2027-12-31', 'Stand zum 31.12.2027', 2500, 3000, 'Referenzstand 1.475', null, 30),
  (2027, 'reach', 'tiktok_followers', 'TikTok-Follower', 'snapshot', '2027-01-01', '2027-12-31', 'Stand zum 31.12.2027', 2000, 2500, 'Referenzstand 1.040', null, 40),
  (2027, 'performance', 'spotify_plays', 'Spotify-Plays im Jahr', 'month_sum', '2027-01-01', '2027-12-31', 'Summe Januar–Dezember 2027', 33000, 37000, null, null, 10),
  (2027, 'performance', 'episodes', 'Veröffentlichte Folgen im Jahr', 'episodes', '2027-01-01', '2027-12-31', 'veröffentlicht 2027', 26, 26, null, null, 20),
  (2028, 'reach', 'youtube_subscribers', 'YouTube-Abonnenten', 'snapshot', '2028-01-01', '2028-12-31', 'Stand zum 31.12.2028', 10500, 13500, null, null, 10),
  (2028, 'reach', 'spotify_followers', 'Spotify-Follower', 'snapshot', '2028-01-01', '2028-12-31', 'Stand zum 31.12.2028', 2600, 3150, null, null, 20),
  (2028, 'performance', 'spotify_plays', 'Spotify-Plays im Jahr', 'month_sum', '2028-01-01', '2028-12-31', 'Summe Januar–Dezember 2028', 40000, 47000, null, null, 10),
  (2028, 'performance', 'episodes', 'Veröffentlichte Folgen im Jahr', 'episodes', '2028-01-01', '2028-12-31', 'veröffentlicht 2028', 26, 26, null, null, 20)
on conflict (year, metric_key) do nothing;

-- The only dated actual value from the brief: YouTube 4.600 subscribers on 27.10.2026.
insert into public.podcast_metric_values (metric_key, value, measured_on, note)
select 'youtube_subscribers', 4600, '2026-10-27', 'Stand laut Strategie-Vorgabe'
where not exists (select 1 from public.podcast_metric_values where metric_key = 'youtube_subscribers' and measured_on = '2026-10-27');

-- Milestones as general to-dos (idempotent via strategy_key).
insert into public.podcast_todos (id, text, done, status, priority, due_date, project_id, strategy_year, strategy_key)
select gen_random_uuid()::text, m.text, false, 'open', 'medium', m.due::date, p.id, m.year, m.key
from (values
  ('2026-logo',            2026, 'Logo-Entscheidung treffen',                                     null,         'Marketing & Wachstum'),
  ('2026-email',           2026, 'Podcast-E-Mail-Adresse einrichten',                             null,         'Organisation & Business'),
  ('2026-tax',             2026, 'Steuerberatertermin zu GbR und Gewerbe',                        null,         'Finanzen & Steuern'),
  ('2026-sponsor-medilearn', 2026, 'Sponsoring-Anfrage Medi-Learn',                               null,         'Marketing & Wachstum'),
  ('2026-sponsor-thieme',  2026, 'Sponsoring-Anfrage Thieme',                                     null,         'Marketing & Wachstum'),
  ('2027-first-partner',   2027, 'Ersten zahlenden Partner gewinnen, der die laufenden Kosten deckt', '2027-06-30', 'Marketing & Wachstum'),
  ('2027-time-limit',      2027, 'Podcast-Arbeitszeit auf max. 4 Stunden pro Person und Woche begrenzen', null, 'Interne Prozesse'),
  ('2027-legal-check',     2027, 'Berufsrechts- und HWG-Check vor der Approbation (Dez. 2027)',   '2027-11-30', 'Organisation & Business'),
  ('outsource_editing',    2028, 'Langfolgenschnitt auslagern (ab Ø 300 € Monatsumsatz)',        null,         'Interne Prozesse')
) as m(key, year, text, due, project)
left join public.podcast_task_projects p on p.name = m.project
on conflict (strategy_key) do nothing;
