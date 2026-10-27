# 🎙️ Glans & Gloria – Podcast Manager 2.0

Internes Produktionstool für den medizinischen Podcast **Glans & Gloria** (Nils & Leo).
Single-File-App (`index.html`, Vanilla HTML/CSS/JS, kein Build-Step) – gehostet über GitHub Pages
(`https://nilslabitzke.github.io/podcast-planer/`), Daten in Supabase (Projekt `wkqaktxdrtohwzrtpjrh`).
Die App enthält **keine KI-Generierung**: Inhalte werden separat (Claude-Skills) erstellt und eingefügt.

---

## Bedienung im Überblick

| Bereich | Wofür |
|---|---|
| **Dashboard** | Startseite: Kennzahlen, Handlungsbedarf, nächste Termine und Posts |
| **Folgen** | Planer (Raster/Kanban), Folgendetail mit Workflow-Checkliste, Archiv |
| **Zeitstrahl** | Chronologische Übersicht aller Folgen und Termine |
| **Aufgaben** | Allgemeine To-dos, Folgenaufgaben, alle Aufgaben |
| **Ideen** | Ideenpool, Übernahme in den Planer |
| **Experten** | Experten-CRM mit Kontaktchronik und Follow-ups |
| **Leitfäden** | SOPs mit Checklisten und Versionen |
| **Kalender** | Social-Media-Kalender, eigene Termine, Apple-Kalender-Abo |
| **Strategie** | Ziele und Verbesserungsvorschläge |

**Überall verfügbar**
- 🔍 **Globale Suche** – Sidebar „Suchen“, Lupe in der mobilen Kopfzeile oder **⌘K / Strg+K**.
  Durchsucht Folgen, Experten, Ideen, allgemeine Aufgaben, Produktionsschritte und Leitfäden.
  Pfeiltasten + Enter zum Öffnen, Esc schließt.
- ➕ **Plus-Button** (unten rechts): Neue Folge, Idee, Aufgabe, Experte oder Termin.
- Hash-Navigation (`#dashboard`, `#folge/<id>`, `#experte/<id>` …) – Links lassen sich teilen, Zurück-Taste funktioniert.
- Sidebar einklappbar (Desktop), Tab-Leiste + Menü (Mobil), Dark/Light Mode.

---

## Funktionen

### Dashboard
- Kennzahlen: Nächste Veröffentlichung, Nächste Aufnahme, Aktive Folgen, Offene Aufgaben (Nils / Leo / nicht zugewiesen),
  Überfällige Aufgaben, Offene Expertenanfragen, fällige Follow-ups, nächster Social-Media-Post.
- Karten: Nächste Veröffentlichungen, Nächste Social-Media-Posts (direkt abhakbar), Produktionsfortschritt,
  Nächste Aufnahmen, Aufgaben nach Person (Nils · Leo · Nicht zugewiesen), Experten-Follow-ups.
- **Handlungsbedarf** – erscheint nur bei echten, aus den Daten ableitbaren Fällen:
  - überfällige allgemeine Aufgaben (Deadline überschritten, nicht erledigt)
  - überfällige Produktionsschritte (nur mit ausdrücklich gesetzter Deadline)
  - Release innerhalb von 7 Tagen (oder kürzlich vergangen) mit offenen Produktions-/Upload-Schritten
  - Aufnahme in ≤ 7 Tagen, aber Vorbereitung (Fragenerstellung) nicht abgeschlossen
  - Social-Media-Posts, deren Termin verstrichen ist und die nicht veröffentlicht sind (letzte 14 Tage)
  - fällige Experten-Follow-ups
  Ohne Treffer: „✅ Kein Handlungsbedarf“.

### Folgen
- Zweiwöchentlicher Release-Rhythmus als Jahresraster (Drag & Drop) oder Kanban nach Status; Zusatzfolgen über „+“.
- Produktionsstatus: Geplant · Gast angefragt · Aufnahme terminiert · Aufgenommen · Im Schnitt · Bereit zur Veröffentlichung · Veröffentlicht.
- Vergangene Folgen wandern ins Archiv.
- Folgen-Infos: Gast, Links (Riverside, Drive, Spotify, YouTube, Apple, Website), Freigaben (Folge, Reels, Cover, Social-Posts), Notizen, Transkript.
- Workflow-Checkliste (Produktion, Plattform-Upload, Social Media, LinkedIn): je Schritt Zuständigkeit, Deadline, Status, Link, Beschreibung, Inhalt, Erledigt-Datum.

### Leitfäden (SOPs)
- Titel, Kategorie, Arbeitsanweisung, Checkliste mit Pflicht-/optionalen Punkten, verknüpfte Produktionsschritte.
- Entwurf → „Freigeben“ erzeugt eine Version (`podcast_guide_versions`); nur freigegebene Versionen gelten für Folgen.
- Pro Folge wird die verwendete Version gespeichert; ein Schritt lässt sich erst abschließen, wenn alle Pflichtpunkte erfüllt sind.
  Abgeschlossene Schritte bleiben unverändert, offene können auf eine neue Version aktualisiert werden.

### Aufgaben
- Eingang „Nicht zugewiesen“ → an Leo oder Nils verteilen; Spalten Leo / Nils mit einklappbaren erledigten Aufgaben.
- Felder: Titel, Beschreibung, Verantwortlich, Priorität, Deadline, Status, Projekt/Kategorie (`podcast_task_projects`), Unteraufgaben.
- Ansichten: Allgemeine To-dos · Folgenaufgaben (direkt aus den Folgen, keine Kopien) · Alle Aufgaben (inkl. Posts und Follow-ups).
- Filter: Alle, Nils, Leo, Nicht zugewiesen, Überfällig, Diese Woche, Erledigt.
- Standard-Fälligkeit von Folgenaufgaben: Produktion/Upload bis Release, Social Media/LinkedIn bis Release + 13 Tage.

### Experten (CRM)
- Profil: Name, Titel, Fachgebiet, Spezialisierung, Klinik/Uni, E-Mail, Website, Social Media, Drive-Link, Notizen, Zuständigkeit.
- Status: Wunschgast → Recherche → Anfrage vorbereiten → Anfrage versendet → Rückmeldung → Zusage → Termin → Aufnahme → Folge veröffentlicht (bzw. Abgesagt / Zurückgestellt).
- Kontaktchronik mit nächster Wiedervorlage; automatisches Follow-up bei „Anfrage versendet“ ohne Antwort nach N Tagen (Standard 10, einstellbar).
- Verknüpfung mit Ideen und Folgen; Freitext-Gastnamen bleiben erhalten, passende Experten werden nur vorgeschlagen.

### Ideenpool
- Titel, Themenpunkte, Kernaussage, Gast, Status (Idee → Gast angefragt → Bestätigt), Drive-Link, Fragenkatalog.
- „In Planer übernehmen“ legt aus einer Idee eine Folge an.

### Social-Media-Kalender
- Posts (`podcast_posts`): Folge, Format, Plattformen, Datum, Uhrzeit, Zuständigkeit, Titel, Beschreibung, Medien-/Veröffentlichungslink, Status.
- Standardvorlage (8 Reels, 3 Instagram-Karussells über 14 Tage ab Release, 2 LinkedIn-Beiträge am 1. und 2. Dienstag nach dem Release um 07:45) – automatisch für neue Folgen, für bestehende per „Standardvorlage anwenden“ ohne Duplikate (`template_key`).
- Woche / Monat / Liste, Filter (Plattform, Folge, Zuständigkeit), Drag & Drop, Duplizieren, Abhaken.
- Verschieben einer Folge verschiebt ihre unveröffentlichten Posts mit; sind alle Posts eines Bereichs veröffentlicht, werden die zugehörigen Folgenaufgaben abgehakt.
- Eigene Termine (`podcast_events`) mit Uhrzeit, Ort, Notizen.
- Das alte Feld `content_plan` bleibt unverändert erhalten.

### Apple-Kalender-Abo (ICS)
- Schreibgeschütztes Abonnement über die Edge Function `calendar-ics` (kein Zwei-Wege-Sync).
- Inhalte wählbar: Aufnahmen, Veröffentlichungen (05:30 Uhr), wichtige Deadlines, Social-Media-Posts, eigene Termine; optional nur Nils oder Leo.
- Geheimer, widerrufbarer Link (`podcast_calendar_feeds`), stabile UIDs, Zeitzone Europe/Berlin.
- Einrichtung: Kalender → „📲 Abonnieren“ → „In Apple Kalender abonnieren“.
- Machbarkeit echter iCloud-CalDAV-Synchronisierung: [`docs/caldav-machbarkeit.md`](docs/caldav-machbarkeit.md).

### Zusammenarbeit & Speichern
- Echtzeit-Sync (Supabase Realtime): Änderungen von Nils und Leo erscheinen ohne Neuladen.
- Versionsprüfung (`updated_at`) mit 3-Wege-Merge – gleichzeitige Änderungen an verschiedenen Feldern gehen nicht verloren.
- Schreibwarteschlangen pro Eintrag, Statusanzeige „Speichert… / Gespeichert ✓ / Live / Nicht gespeichert – erneut versuchen“,
  Warnung beim Schließen mit ungespeicherten Änderungen.
- Fehler (Laden, Speichern, keine Verbindung) werden als Hinweis bzw. Fehlerzustand mit „Erneut versuchen“ angezeigt.

---

## Technik

| Schicht | Technologie |
|---|---|
| Frontend | Vanilla HTML/CSS/JS in `index.html`, Service Worker `sw.js` (network-first), `manifest.json` |
| Hosting | GitHub Pages |
| Datenbank | Supabase Postgres + PostgREST, Row Level Security |
| Realtime | Supabase Realtime (Websocket) |
| Edge Functions | `backup` (wöchentliches JSON-Backup), `calendar-ics` (ICS-Feed) |

### Tabellen
`podcast_episodes`, `podcast_ideas`, `podcast_todos`, `podcast_task_projects`, `podcast_guides`, `podcast_guide_versions`,
`podcast_experts`, `podcast_expert_contacts`, `podcast_expert_ideas`, `podcast_expert_episodes`, `podcast_posts`,
`podcast_events`, `podcast_calendar_feeds`, `podcast_settings`, `podcast_goals`, `podcast_improvements`, `app_users`.
Nicht mehr in der App genutzt, aber unverändert erhalten: `podcast_prompts`, `podcast_expenses`, `podcast_income`, `podcast_settlements`.

### Migrationen (`supabase/migrations/`)
| Datei | Inhalt | Status |
|---|---|---|
| `20261024_phase1a_members.sql` | `app_users`, `is_app_user()`, Mitglieder-Policies | angewendet |
| `20261024_phase1b_drop_anon.sql` | entfernt anonymen Zugriff | **noch nicht angewendet** |
| `20261024_phase3_tasks.sql` | Aufgaben: Status, Priorität, Projekte, Unteraufgaben | angewendet |
| `20261024_phase4_episodes_guides.sql` | Folgenstatus, Leitfäden, Versionen | angewendet |
| `20261024_phase5_experts.sql` | Experten-CRM | angewendet |
| `20261025_phase6_posts.sql` | `podcast_posts` (+ Übernahme aus `content_plan`) | angewendet |
| `20261025_phase7_calendar_feed.sql` | `podcast_events`, `podcast_calendar_feeds` | angewendet |
| `20261027_linkedin_two_posts.sql` | kommende Folgen: 2 LinkedIn-Posts dienstags 07:45 | angewendet |

Alle Migrationen sind additiv; es wurden keine produktiven Tabellen gelöscht oder zurückgesetzt.

---

## Login & Sicherheit
- Login per E-Mail-Link (Supabase Auth, kein Passwort). Zugriff nur für E-Mails in `app_users`.
- Übergangsphase: anonymer Zugriff ist noch offen (`AUTH_REQUIRED = false` in `index.html`).
  **Umstellung**, sobald Nils und Leo sich erfolgreich angemeldet haben:
  1. In Supabase → Authentication → URL Configuration die Site-URL und Redirect-URL `https://nilslabitzke.github.io/podcast-planer/` eintragen.
  2. Leos E-Mail in `app_users` eintragen.
  3. `20261024_phase1b_drop_anon.sql` ausführen.
  4. In `index.html` `AUTH_REQUIRED = true` setzen und deployen.
- Benutzereingaben werden beim Rendern escaped (`esc`, `jsArg`); Links nur mit `http(s)`/`mailto` (`safeUrl`).

## Datensicherung & Wiederherstellung
- **Automatisch:** jeden Montag 03:00 UTC sichert die Edge Function `backup` alle Tabellen als JSON in den privaten Bucket `backups` (12 Versionen).
- **Manuell:** 💾-Button in der App lädt alle Inhaltstabellen als JSON herunter.
- Kopien zusätzlich außerhalb von Supabase aufbewahren (z. B. `Desktop/Podcast/PodcastBackups/`), **nicht** im öffentlichen Repo.
- Wiederherstellen (löscht nie, Upsert per ID; zuerst Probelauf):
  ```bash
  python3 scripts/restore-backup.py backup.json
  ```
  ```bash
  SUPABASE_SERVICE_KEY=... python3 scripts/restore-backup.py backup.json --apply
  ```

## Lokale Entwicklung
Kein Build-Step. Lokal mit einem statischen Server starten (Service Worker braucht http):
```bash
python3 -m http.server 3456
```
Dann `http://localhost:3456` öffnen. Deployment: `index.html` auf `main` → GitHub Pages.

---

## Autoren
**Nils Labitzke & Leo** – Glans & Gloria Podcast
