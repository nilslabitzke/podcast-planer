-- Finanzen: optional automatic booking of due recurring payments (direct debit / subscriptions).
-- Applied: 2026-10-27. Additive only. Default false: nothing is booked unless a person enables it per item.
-- Duplicates are impossible thanks to unique (recurring_id, period_key) on podcast_fin_bookings.
alter table public.podcast_fin_recurring add column if not exists auto_book boolean not null default false;
