-- Produktionsleitlinien (SOPs) v1.0 + section links (additive, backward compatible).
-- Applied: 2026-10-27. Backups before: backup-2026-10-27.json (bucket) and
-- PodcastBackups/podcast_{episodes,guides,guide_versions}-2026-10-27-pre-sop.json (local).
--
-- Guide checklist items: {id, text, heading?: true}. Headings group the items; a step can be
-- linked to only some sections of a guide via step_sections {stepId: [headingId, ...]}
-- (no entry = whole guide). Step id "reel" = every single reel/short.
-- Completion confirmations live in podcast_episodes.tasks (no new table):
--   tasks.<step>.sopConfirmation = {by, byEmail, at, guides: [{id, version, title, sections}]}
--   tasks.reels_download.reels[i].sopConfirmation (same shape, per reel)
-- Existing done states are not touched; no confirmations are created retroactively.

alter table public.podcast_guides add column if not exists step_sections jsonb not null default '{}'::jsonb;

with g as (
  insert into public.podcast_guides (title, category, instructions, checklist, step_ids, step_sections, version, released_at) values
  ('Allgemeine Bildgestaltung', 'Produktionsstandards',
   'Gilt für die vollständige Podcastfolge sowie für alle Reels und Shorts.',
   $j$[
     {"id":"bg1","text":"Bilder der Personen zentrieren."},
     {"id":"bg2","text":"Die Augenachse liegt im unteren Bereich des oberen Bilddrittels."},
     {"id":"bg3","text":"Personen nicht ungünstig am Bildrand abschneiden."},
     {"id":"bg4","text":"Personen nicht zu klein im unteren Bildbereich zeigen."},
     {"id":"bg5","text":"Auch bei wechselnden Kameraansichten und Layouts auf die korrekte Bildausrichtung achten."}
   ]$j$::jsonb, '{schnitt,reel}', '{}'::jsonb, 1, now()),
  ('Videobearbeitung der Podcastfolge', 'Produktionsstandards',
   'Gilt für die vollständige Folge. Zusätzlich gilt der Leitfaden „Allgemeine Bildgestaltung“.',
   $j$[
     {"id":"vb_h_ton","text":"Bearbeitungsmodus und Ton","heading":true},
     {"id":"vb1","text":"Im Bearbeitungsmodus alle drei Spuren ausgeklappt lassen."},
     {"id":"vb2","text":"Alle drei Spuren kontrollieren."},
     {"id":"vb3","text":"Besonders auf Echo und störende Tonüberlagerungen achten."},
     {"id":"vb4","text":"Ignorierte bzw. unbeantwortete Fragen der Hosts herausschneiden."},
     {"id":"vb5","text":"Versprecher entfernen – außer sie bleiben bewusst als witziger Moment erhalten."},
     {"id":"vb6","text":"Überflüssige „Ähms“ reduzieren."},
     {"id":"vb7","text":"Zu lange Pausen kürzen, ohne den natürlichen Gesprächsfluss zu zerstören."},
     {"id":"vb_h_design","text":"Videodesign","heading":true},
     {"id":"vb8","text":"Schwarzen Rand mit Dicke 6 einstellen."},
     {"id":"vb9","text":"Rundung des Rahmens auf 6 einstellen."},
     {"id":"vb10","text":"Alle automatischen KI-Bearbeitungsfunktionen deaktivieren."},
     {"id":"vb11","text":"Allgemeine Bildgestaltung einhalten (eigener Leitfaden)."},
     {"id":"vb_h_hook","text":"Hook und Übergänge","heading":true},
     {"id":"vb12","text":"Hook-Szenen immer durch einen Swoosh trennen."},
     {"id":"vb13","text":"Den Ton des Swoosh deaktivieren."},
     {"id":"vb14","text":"Zwischen Hook-Szenen jeweils zwei Ausblendungen als Übergang verwenden."},
     {"id":"vb_h_intro","text":"Intro und Musik","heading":true},
     {"id":"vb15","text":"Die Intromusik über 8 Sekunden auslaufen lassen."},
     {"id":"vb16","text":"Lautstärke der Intromusik auf 65 % einstellen."},
     {"id":"vb17","text":"Verbindliche Intro-Abfolge: 1. Intro → 2. Swoosh → 3. Call to Follow → 4. Swoosh → 5. Start der eigentlichen Podcastfolge."},
     {"id":"vb18","text":"Die Reihenfolge bei jeder Folge kontrollieren."}
   ]$j$::jsonb, '{hook,schnitt}', '{"hook":["vb_h_hook","vb_h_intro"]}'::jsonb, 1, now()),
  ('Plattform-Upload', 'Produktionsstandards',
   'Gilt für den Upload der Folge auf Spotify, YouTube und Apple Podcasts.',
   $j$[
     {"id":"pu_h_desc","text":"Folgenbeschreibung","heading":true},
     {"id":"pu1","text":"Eine sinnvolle, verständliche und inhaltlich passende Folgenbeschreibung verwenden."},
     {"id":"pu2","text":"Maximal 5 Stichpunkte in der Folgenbeschreibung."},
     {"id":"pu3","text":"Die fertige Beschreibung vor dem Upload einmal kurz durchlesen."},
     {"id":"pu4","text":"Auf offensichtliche inhaltliche Fehler, Tippfehler und unpassende Formulierungen achten."},
     {"id":"pu_h_kap","text":"Kapitel und Keywords","heading":true},
     {"id":"pu5","text":"Kapitelmarken unbedingt einfügen."},
     {"id":"pu6","text":"Kapitelüberschriften und Zeitstempel kontrollieren."},
     {"id":"pu7","text":"Keywords unterhalb der Kapitel einfügen."},
     {"id":"pu8","text":"Vor Veröffentlichung prüfen, ob Beschreibung, Kapitel und Keywords vollständig vorhanden sind."}
   ]$j$::jsonb, '{shownotes,kapitel,upload}', '{"shownotes":["pu_h_desc"],"kapitel":["pu_h_kap"]}'::jsonb, 1, now()),
  ('Reels und Shorts', 'Produktionsstandards',
   'Gilt für jedes einzelne Reel und jeden YouTube Short. Zusätzlich gilt der Leitfaden „Allgemeine Bildgestaltung“.',
   $j$[
     {"id":"rs_h_bild","text":"Bildgestaltung","heading":true},
     {"id":"rs1","text":"Allgemeine Bildgestaltung einhalten (eigener Leitfaden)."},
     {"id":"rs2","text":"Bildausschnitte und Ausrichtung beim Wechsel zwischen Split- und Single-Screen kontrollieren."},
     {"id":"rs_h_split","text":"Hook-Text im Splitscreen","heading":true},
     {"id":"rs3","text":"Hook-Text mittig zwischen bzw. im Zentrum der Bildaufteilung positionieren."},
     {"id":"rs4","text":"Darauf achten, dass Gesichter nicht verdeckt werden."},
     {"id":"rs_h_single","text":"Hook-Text im Single-Screen","heading":true},
     {"id":"rs5","text":"Hook-Text auf oberer Kopfhöhe oder auf Brusthöhe platzieren."},
     {"id":"rs6","text":"Der Hook-Text darf das Gesicht nicht verdecken."}
   ]$j$::jsonb, '{reel}', '{}'::jsonb, 1, now())
  returning id, title, instructions, checklist
)
insert into public.podcast_guide_versions (guide_id, version, title, instructions, checklist)
select id, 1, title, instructions, checklist from g;
