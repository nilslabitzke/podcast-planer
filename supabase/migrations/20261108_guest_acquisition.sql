-- Gästeakquise. Builds on the existing structures, no parallel guest table:
--   podcast_experts          = master data (+ phone, salutation)
--   podcast_expert_ideas     = one request per expert and idea (+ role, contact status, assignee, notes)
--   podcast_expert_contacts  = timeline (+ idea_id, kind, status_after, next_action); expert-wide history stays
--   podcast_settings         = follow-up intervals, e-mail templates, id of the acquisition guide
-- Additive and repeatable. Existing ideas, guest texts, e-mails and contacts are not changed.

alter table public.podcast_experts add column if not exists phone text;
alter table public.podcast_experts add column if not exists salutation text;
alter table public.podcast_ideas add column if not exists key_question text;

alter table public.podcast_expert_ideas add column if not exists id uuid not null default gen_random_uuid();
alter table public.podcast_expert_ideas add column if not exists role text not null default 'alt';
alter table public.podcast_expert_ideas add column if not exists contact_status text not null default 'researched';
alter table public.podcast_expert_ideas add column if not exists assignee text;
alter table public.podcast_expert_ideas add column if not exists notes text;
alter table public.podcast_expert_ideas add column if not exists episode_id text references public.podcast_episodes(id) on delete set null;
alter table public.podcast_expert_ideas add column if not exists created_by text;
alter table public.podcast_expert_ideas add column if not exists updated_at timestamptz not null default now();
do $$ begin
  alter table public.podcast_expert_ideas add constraint podcast_expert_ideas_id_key unique (id);
exception when duplicate_object or duplicate_table then null; end $$;
do $$ begin
  alter table public.podcast_expert_ideas add constraint podcast_expert_ideas_role_check check (role in ('wish','alt1','alt2','alt'));
exception when duplicate_object then null; end $$;
do $$ begin
  alter table public.podcast_expert_ideas add constraint podcast_expert_ideas_status_check check (contact_status in ('researched','sent','interested','scheduling','confirmed','declined','dormant','do_not_contact'));
exception when duplicate_object then null; end $$;
do $$ begin
  alter table public.podcast_expert_ideas add constraint podcast_expert_ideas_assignee_check check (assignee in ('nils','leo'));
exception when duplicate_object then null; end $$;

alter table public.podcast_expert_contacts add column if not exists idea_id text references public.podcast_ideas(id) on delete set null;
alter table public.podcast_expert_contacts add column if not exists kind text not null default 'other';
alter table public.podcast_expert_contacts add column if not exists status_after text;
alter table public.podcast_expert_contacts add column if not exists next_action text;
alter table public.podcast_expert_contacts add column if not exists created_by text;
do $$ begin
  alter table public.podcast_expert_contacts add constraint podcast_expert_contacts_kind_check check (kind in ('first_request','followup1','followup2','reply','other','note','status','assignee'));
exception when duplicate_object then null; end $$;
create index if not exists podcast_expert_contacts_idea_idx on public.podcast_expert_contacts (idea_id);

-- "Als Aufgabe übernehmen": at most one open general task per request.
alter table public.podcast_todos add column if not exists acq_request_id uuid references public.podcast_expert_ideas(id) on delete set null;
create unique index if not exists podcast_todos_acq_open_uq on public.podcast_todos (acq_request_id) where acq_request_id is not null and not done;

-- Central settings (editable in Ideen → Akquise).
insert into public.podcast_settings (key, value, updated_at) values
  ('acq_intervals', '{"fu1": 7, "fu2": 17, "alt": 24}'::jsonb, now()),
  ('acq_templates', jsonb_build_object(
    'first', jsonb_build_object('subject', 'Podcast-Anfrage: {thema}', 'body',
      E'{anrede}\n\nwir sind Nils und Leo und machen gemeinsam den Podcast {podcast}. Für eine kommende Folge beschäftigen wir uns mit dem Thema „{thema}“ – und würden Sie sehr gerne als Gast dabeihaben.\n\nUns interessiert vor allem: {fragestellung}\n\nTermin und Ablauf stimmen wir gerne ganz nach Ihrem Kalender ab. Hätten Sie grundsätzlich Interesse? Dann melden wir uns mit allen Details.\n\nViele Grüße\n{absender}\n{podcast}'),
    'fu1', jsonb_build_object('subject', 'Re: Podcast-Anfrage: {thema}', 'body',
      E'{anrede}\n\nich wollte noch einmal kurz an unsere Anfrage zum Thema „{thema}“ erinnern. Wir würden uns sehr freuen, Sie bei {podcast} begrüßen zu dürfen.\n\nFalls es zeitlich gerade nicht passt, ist das natürlich kein Problem – eine kurze Rückmeldung hilft uns trotzdem sehr.\n\nViele Grüße\n{absender}\n{podcast}'),
    'fu2', jsonb_build_object('subject', 'Re: Podcast-Anfrage: {thema}', 'body',
      E'{anrede}\n\nich melde mich ein letztes Mal zu unserer Anfrage zum Thema „{thema}“. Wenn es aktuell nicht passt, verstehen wir das gut – dann melden wir uns nicht weiter dazu.\n\nÜber eine kurze Nachricht, ob grundsätzlich Interesse besteht, würden wir uns aber sehr freuen.\n\nViele Grüße\n{absender}\n{podcast}')
  ), now())
on conflict (key) do nothing;

-- Guide "Gästeakquise – Standardprozess" v1.0 (released), only once.
do $$
declare gid uuid; items jsonb;
begin
  if exists (select 1 from public.podcast_guides where title = 'Gästeakquise – Standardprozess') then
    select id into gid from public.podcast_guides where title = 'Gästeakquise – Standardprozess' limit 1;
  else
    items := '[
      {"id":"ga_h1","text":"Schritt 1: Folgenidee vorbereiten","heading":true},
      {"id":"ga1","text":"Klares, problemorientiertes Folgenthema definieren."},
      {"id":"ga2","text":"Das wichtigste medizinische Missverständnis benennen."},
      {"id":"ga3","text":"Den konkreten Mehrwert für die Zuhörenden festlegen."},
      {"id":"ga4","text":"Mindestens einen geeigneten Wunschgast recherchieren."},
      {"id":"ga5","text":"Nach Möglichkeit zwei zusätzliche Gastalternativen recherchieren."},
      {"id":"ga6","text":"Kontaktdaten prüfen und dokumentieren."},
      {"id":"ga7","text":"Priorität der Folgenidee festlegen."},
      {"id":"ga_h2","text":"Schritt 2: Experten auswählen","heading":true},
      {"id":"ga8","text":"Fachliche Expertise zum konkreten Thema."},
      {"id":"ga9","text":"Erfahrung in Wissenschaft oder klinischer Praxis."},
      {"id":"ga10","text":"Fähigkeit, komplexe Inhalte verständlich zu erklären."},
      {"id":"ga11","text":"Potenzial für interessante Aussagen und Diskussionen."},
      {"id":"ga12","text":"Thematische Passung zur Zielgruppe von Glans & Gloria."},
      {"id":"ga13","text":"Erreichbarkeit und voraussichtliche Verfügbarkeit."},
      {"id":"ga14","text":"Nicht ausschließlich nach Bekanntheit auswählen."},
      {"id":"ga_h3","text":"Schritt 3: Erste Anfrage","heading":true},
      {"id":"ga15","text":"Persönlich und individuell formulieren."},
      {"id":"ga16","text":"Kurz und professionell bleiben."},
      {"id":"ga17","text":"Das konkrete Thema nennen."},
      {"id":"ga18","text":"Den Mehrwert der Folge erklären."},
      {"id":"ga19","text":"Glans & Gloria knapp vorstellen."},
      {"id":"ga20","text":"Einen unkomplizierten nächsten Schritt anbieten."},
      {"id":"ga21","text":"Keine übertriebenen Komplimente."},
      {"id":"ga22","text":"Keine wissenschaftlichen Arbeiten oder persönlichen Bezüge erfinden."},
      {"id":"ga23","text":"Die Anfrage wird extern versendet und anschließend ausdrücklich als versendet dokumentiert."},
      {"id":"ga_h4","text":"Schritt 4: Follow-up-System","heading":true},
      {"id":"ga24","text":"Tag 0: Erstanfrage · Tag 7: Follow-up 1 · Tag 17: Follow-up 2 · Tag 24: Gastalternative prüfen (Empfehlungen, zentral einstellbar)."},
      {"id":"ga25","text":"Follow-ups freundlich, kurz und respektvoll halten."},
      {"id":"ga26","text":"Nach Absage, Zusage oder der Bitte um keine weiteren Nachrichten keine weiteren Follow-ups."},
      {"id":"ga27","text":"Echtes Interesse beendet den Ablauf für unbeantwortete Anfragen – weiter mit der Terminabstimmung."},
      {"id":"ga_h5","text":"Schritt 5: Gastalternativen","heading":true},
      {"id":"ga28","text":"Pro Folgenidee möglichst Wunschgast, Alternative 1 und Alternative 2 hinterlegen."},
      {"id":"ga29","text":"Grundsätzlich nicht mehrere Gäste für dasselbe Thema gleichzeitig aktiv anfragen – Ausnahmen nur nach bewusster Bestätigung."},
      {"id":"ga30","text":"Antwortet der Wunschgast nicht, nach dem definierten Zeitraum die nächste Alternative kontaktieren."},
      {"id":"ga31","text":"Bisherige Anfragen und Kontaktverläufe bleiben dokumentiert."},
      {"id":"ga_h6","text":"Schritt 6: Zusage und Planung","heading":true},
      {"id":"ga32","text":"Zusage dokumentieren und weitere parallele Anfragen prüfen."},
      {"id":"ga33","text":"Terminabstimmung organisieren."},
      {"id":"ga34","text":"Bestätigten Gast der Folgenidee zuordnen und relevante Informationen in den Folgenplaner übernehmen."},
      {"id":"ga35","text":"Keine weiteren Follow-ups für diese Anfrage; andere Gäste nicht automatisch absagen."},
      {"id":"ga_h7","text":"Schritt 7: Kontakthistorie pflegen","heading":true},
      {"id":"ga36","text":"Nach jeder relevanten Kommunikation dokumentieren: Kontaktart, Datum, tatsächlicher Status, Rückmeldung, nächste Aktion, Zuständigkeit (Nils oder Leo)."},
      {"id":"ga37","text":"Der Kontaktverlauf bleibt dauerhaft erhalten."}
    ]'::jsonb;
    insert into public.podcast_guides (title, category, instructions, checklist, step_ids, version, released_at)
    values ('Gästeakquise – Standardprozess', 'Gästeakquise',
            'Arbeitsstandard für die Gästeakquise – keine zusätzliche Aufgabenliste. Anfragen, Follow-ups und Zusagen werden in Ideen → Akquise dokumentiert.',
            items, '{}', 1, now())
    returning id into gid;
    insert into public.podcast_guide_versions (guide_id, version, title, instructions, checklist)
    values (gid, 1, 'Gästeakquise – Standardprozess',
            'Arbeitsstandard für die Gästeakquise – keine zusätzliche Aufgabenliste. Anfragen, Follow-ups und Zusagen werden in Ideen → Akquise dokumentiert.', items);
  end if;
  insert into public.podcast_settings (key, value, updated_at) values ('acq_guide_id', to_jsonb(gid::text), now()) on conflict (key) do nothing;
end $$;

-- Legacy guest texts: only a unique, exact match with an existing profile is linked automatically
-- (as Wunschgast). Everything else stays as text and is taken over in the app on request.
-- "Gast angefragt" becomes the status "Anfrage versendet" without a date; no timeline entries.
insert into public.podcast_expert_ideas (expert_id, idea_id, role, contact_status)
select x.id, i.id, 'wish', case i.status when 'contacted' then 'sent' when 'confirmed' then 'confirmed' else 'researched' end
from public.podcast_ideas i
join public.podcast_experts x
  on lower(trim(i.guests)) in (lower(trim(x.name)), lower(trim(coalesce(x.title || ' ', '') || x.name)))
where i.guests is not null
  and (select count(*) from public.podcast_experts y where lower(trim(y.name)) = lower(trim(x.name))) = 1
on conflict (expert_id, idea_id) do nothing;
