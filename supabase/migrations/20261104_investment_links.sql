-- Product links per investment, shared by the list and the studio view. Additive; the offer price
-- is for comparison only and never touches podcast_investments.price_cents.
create table if not exists public.podcast_investment_links (
  id uuid primary key default gen_random_uuid(),
  investment_id uuid not null references public.podcast_investments(id) on delete cascade,
  label text not null check (length(trim(label)) > 0),
  url text not null check (url ~* '^https?://'),
  offer_price_cents bigint check (offer_price_cents is null or (offer_price_cents >= 0 and offer_price_cents <= 100000000)),
  created_by text, updated_by text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists podcast_investment_links_investment_idx on public.podcast_investment_links (investment_id);

alter table public.podcast_investment_links enable row level security;
create policy anon_all_investment_links on public.podcast_investment_links for all to anon using (true) with check (true);
create policy members_all_investment_links on public.podcast_investment_links for all to authenticated using (public.is_app_user()) with check (public.is_app_user());
alter publication supabase_realtime add table public.podcast_investment_links;
