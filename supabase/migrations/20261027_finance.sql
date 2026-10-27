-- Finanzen: categories, recurring items (planning), actual bookings (cash flow), month completeness,
-- booking change log, private receipt storage. Additive only.
-- Applied: 2026-10-27. Backup before: backup-2026-10-27.json (bucket).
--
-- Money is stored as integer cents (EUR). Recurring items are planning data only: their monthly
-- equivalent is computed in the app and never written as bookings. Only bookings with
-- status 'paid' count as actual income/expense. The old tables podcast_expenses / podcast_income /
-- podcast_settlements stay untouched (legacy, importable per item via legacy_ref).

create table if not exists public.podcast_fin_categories (
  id uuid primary key default gen_random_uuid(),
  kind text not null check (kind in ('income','expense')),
  name text not null check (length(trim(name)) > 0),
  key text unique,                       -- stable key for built-in categories (e.g. adsense)
  sort integer not null default 100,
  archived boolean not null default false,
  created_at timestamptz not null default now(),
  unique (kind, name)
);

create table if not exists public.podcast_fin_recurring (
  id uuid primary key default gen_random_uuid(),
  kind text not null check (kind in ('income','expense')),
  name text not null check (length(trim(name)) > 0),
  category_id uuid references public.podcast_fin_categories(id) on delete set null,
  amount_cents bigint not null check (amount_cents > 0 and amount_cents <= 100000000),
  billing_interval text not null check (billing_interval in ('monthly','quarterly','semiannual','yearly')),
  start_date date not null default current_date,
  end_date date,
  next_due date,
  status text not null default 'active' check (status in ('active','paused','ended')),
  notes text,
  receipt_path text,
  created_by text, updated_by text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.podcast_fin_bookings (
  id uuid primary key default gen_random_uuid(),
  kind text not null check (kind in ('income','expense')),
  amount_cents bigint not null check (amount_cents > 0 and amount_cents <= 100000000),
  date date not null default current_date,
  description text not null default '',
  category_id uuid references public.podcast_fin_categories(id) on delete set null,
  recurring_id uuid references public.podcast_fin_recurring(id) on delete set null,
  period_key text,                       -- billing period of a recurring item, e.g. 2026-01 / 2026-Q1 / 2026-H1 / 2026
  status text not null default 'paid' check (status in ('paid','open')),
  receipt_path text,
  episode_id text references public.podcast_episodes(id) on delete set null,
  cooperation text,
  note text,
  legacy_ref text unique,                -- e.g. expenses:1 when taken over from the old tables
  created_by text, updated_by text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (recurring_id, period_key)      -- a recurring payment can be booked only once per period
);
create index if not exists podcast_fin_bookings_date_idx on public.podcast_fin_bookings (date);

create table if not exists public.podcast_fin_months (
  year integer not null check (year between 2020 and 2100),
  month integer not null check (month between 1 and 12),
  complete boolean not null default false,
  completed_by text,
  completed_at timestamptz,
  updated_at timestamptz not null default now(),
  primary key (year, month)
);

-- Change log for bookings, written only by trigger (clients can read, never write).
create table if not exists public.podcast_fin_booking_log (
  id bigint generated always as identity primary key,
  booking_id uuid not null,
  action text not null check (action in ('insert','update','delete')),
  actor text,
  at timestamptz not null default now(),
  old_row jsonb,
  new_row jsonb
);
create index if not exists podcast_fin_booking_log_booking_idx on public.podcast_fin_booking_log (booking_id);

create or replace function public.podcast_fin_touch() returns trigger
language plpgsql set search_path = '' as $$
begin new.updated_at := now(); return new; end $$;
create trigger podcast_fin_recurring_touch before update on public.podcast_fin_recurring for each row execute function public.podcast_fin_touch();
create trigger podcast_fin_bookings_touch before update on public.podcast_fin_bookings for each row execute function public.podcast_fin_touch();
create trigger podcast_fin_months_touch before update on public.podcast_fin_months for each row execute function public.podcast_fin_touch();

create or replace function public.podcast_fin_booking_audit() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if tg_op = 'INSERT' then
    insert into public.podcast_fin_booking_log (booking_id, action, actor, new_row) values (new.id, 'insert', new.created_by, to_jsonb(new));
    return new;
  elsif tg_op = 'UPDATE' then
    if to_jsonb(old) - 'updated_at' - 'updated_by' is distinct from to_jsonb(new) - 'updated_at' - 'updated_by' then
      insert into public.podcast_fin_booking_log (booking_id, action, actor, old_row, new_row) values (new.id, 'update', new.updated_by, to_jsonb(old), to_jsonb(new));
    end if;
    return new;
  else
    insert into public.podcast_fin_booking_log (booking_id, action, actor, old_row) values (old.id, 'delete', old.updated_by, to_jsonb(old));
    return old;
  end if;
end $$;
revoke execute on function public.podcast_fin_booking_audit() from public, anon, authenticated;
create trigger podcast_fin_bookings_audit after insert or update or delete on public.podcast_fin_bookings
  for each row execute function public.podcast_fin_booking_audit();

do $$
declare t text;
begin
  foreach t in array array['podcast_fin_categories','podcast_fin_recurring','podcast_fin_bookings','podcast_fin_months']
  loop
    execute format('alter table public.%I enable row level security', t);
    execute format('create policy %I on public.%I for all to anon using (true) with check (true)', 'anon_all_' || replace(t, 'podcast_', ''), t);
    execute format('create policy %I on public.%I for all to authenticated using (public.is_app_user()) with check (public.is_app_user())', 'members_all_' || replace(t, 'podcast_', ''), t);
    execute format('alter publication supabase_realtime add table public.%I', t);
  end loop;
end $$;
-- Log: read-only for clients.
alter table public.podcast_fin_booking_log enable row level security;
create policy anon_read_fin_booking_log on public.podcast_fin_booking_log for select to anon using (true);
create policy members_read_fin_booking_log on public.podcast_fin_booking_log for select to authenticated using (public.is_app_user());

-- Built-in categories (idempotent).
insert into public.podcast_fin_categories (kind, name, key, sort) values
  ('income',  'YouTube AdSense',        'adsense',        10),
  ('income',  'Sponsoring',             'sponsoring',     20),
  ('income',  'Affiliate',              'affiliate',      30),
  ('income',  'Sonstige Einnahmen',     'other_income',   90),
  ('expense', 'Software & Abonnements', 'software',       10),
  ('expense', 'Hosting & Domain',       'hosting',        20),
  ('expense', 'Website & E-Mail',       'website',        30),
  ('expense', 'Equipment',              'equipment',      40),
  ('expense', 'Reisen & Bewirtung',     'travel',         50),
  ('expense', 'Videoschnitt',           'editing',        60),
  ('expense', 'Marketing',              'marketing',      70),
  ('expense', 'Sonstige Ausgaben',      'other_expense',  90)
on conflict (key) do nothing;

-- Receipts: private bucket, members only (not anon – receipts need a signed-in member).
insert into storage.buckets (id, name, public) values ('receipts', 'receipts', false) on conflict (id) do nothing;
create policy receipts_members_select on storage.objects for select to authenticated using (bucket_id = 'receipts' and public.is_app_user());
create policy receipts_members_insert on storage.objects for insert to authenticated with check (bucket_id = 'receipts' and public.is_app_user());
create policy receipts_members_update on storage.objects for update to authenticated using (bucket_id = 'receipts' and public.is_app_user());
create policy receipts_members_delete on storage.objects for delete to authenticated using (bucket_id = 'receipts' and public.is_app_user());

-- Month completeness for revenue now lives in podcast_fin_months; the outsourcing rule setting
-- (podcast_settings.revenue_outsourcing) is reused. podcast_revenue_* tables stay (empty, unused).
