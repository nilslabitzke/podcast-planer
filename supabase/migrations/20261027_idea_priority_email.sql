-- Ideas: priority (existing ideas get 'medium') and an optional expert e-mail.
-- Additive only; no existing column is changed. When an idea is linked to an expert
-- profile, the profile's email (podcast_experts.email) is the central address;
-- guest_email holds the address for ideas without a profile.
alter table public.podcast_ideas add column if not exists priority text not null default 'medium';
alter table public.podcast_ideas add column if not exists guest_email text;
do $$ begin
  alter table public.podcast_ideas add constraint podcast_ideas_priority_check check (priority in ('high','medium','low'));
exception when duplicate_object then null; end $$;
