# 🎙️ Glans & Gloria – Podcast Planer

Internes Produktionstool für den medizinischen Podcast **Glans & Gloria** (Nils & Leo).  
Single-File-App (`index.html`) ohne Build-Step – gehostet via GitHub Pages, Daten in Supabase.

---

## Features

### Planer
- Zweiwöchentlicher Release-Rhythmus als Raster-Übersicht (jahresweise)
- Folgen anlegen, bearbeiten, löschen
- Zusatzfolgen via „+"-Button zwischen regulären Slots
- Fortschrittsanzeige pro Folge (Prozent / Schritte)
- Vergangene/abgeschlossene Folgen werden nach 2 Wochen automatisch blasser dargestellt
- **„Heute & morgen fällig"-Widget** oben auf der Planerseite

### Folgenmanager
- Produktionsstatus pro Folge (unabhängig von der Checkliste): Geplant · Gast angefragt · Aufnahme terminiert · Aufgenommen · Im Schnitt · Bereit zur Veröffentlichung · Veröffentlicht
- Planer als Raster (Jahresübersicht, Drag & Drop) oder Kanban nach Status
- Folgen-Infos: Gast, Links (Riverside, Drive, Spotify, YouTube, Apple, Website), Freigaben (Folge, Reels, Cover, Social-Posts)

### Workflow-Checkliste (pro Folge)
Abschnitte Produktion, Plattform-Upload, Social Media, LinkedIn. Jeder Schritt: Zuständigkeit, Deadline, Status (Offen/In Arbeit/Erledigt), Link, Beschreibung, Inhalt, Erledigt-Datum.

### Leitfäden (SOPs)
- Pro Leitfaden: Titel, Kategorie, Arbeitsanweisung, Checkliste mit Pflicht- und optionalen Punkten, verknüpfte Produktionsschritte
- Entwurf → „Freigeben“ erzeugt eine neue Version (`podcast_guide_versions`); nur freigegebene Versionen gelten für Folgen
- Pro Folge wird die verwendete Version samt Prüfpunkten gespeichert; ein Schritt lässt sich erst abschließen, wenn alle Pflichtpunkte erfüllt sind
- Bereits abgeschlossene Schritte bleiben unverändert; offene Schritte können auf eine neue Version aktualisiert werden

### Content-Kalender (pro Folge)
- 14-Tage-Plan nach Release mit allen geplanten Posts/Reels/Karussells
- Jedes Item: abhakbar + N/L-Zuweisung (Nils / Leo)
- Fertige LinkedIn- und Reel-Kategorien haken automatisch die übergeordnete Workflow-Aufgabe ab

### Inhalte (ohne KI in der App)
Die App generiert keine Inhalte mehr. Titel, Shownotes, Reels, LinkedIn-Posts usw. werden separat (Claude-Skills) erstellt und in die Felder eingefügt. Die Edge Function `podcast-ai` und die Tabelle `podcast_prompts` sind vorerst noch vorhanden, werden aber nicht mehr genutzt.

### Aufgaben
- Eingang „Nicht zugewiesen“ → per Klick an Leo oder Nils verteilen; Spalten Leo (links) / Nils (rechts) mit offenen und einklappbaren erledigten Aufgaben
- Felder: Titel, Beschreibung, Verantwortlich, Priorität, Deadline, Status (Offen/In Arbeit/Erledigt), Projekt/Kategorie, Unteraufgaben
- Kategorien frei bearbeitbar (Tabelle `podcast_task_projects`)
- Ansichten: Allgemeine To-dos · Folgenaufgaben (Produktionsschritte direkt aus den Folgen, keine Kopien) · Alle Aufgaben
- Filter: Alle, Nils, Leo, Nicht zugewiesen, Überfällig, Diese Woche, Erledigt
- Fälligkeit von Folgenaufgaben: Produktion/Upload bis Release, Social Media/LinkedIn bis Release + 13 Tage

### Ideenpool
- Folgenideen sammeln: Titel, Themenpunkte, Kernaussage & G&G, Gast, Status
- Status: 💡 Idee → 📩 Gast angefragt → ✅ Bestätigt
- Google-Drive-Link & Fragenkatalog pro Idee
- **„In Planer übernehmen"** – aus einer bestätigten Idee direkt eine neue Folge anlegen (Titel, Beschreibung, Fragenkatalog werden übertragen)

### Sonstiges
- Dark / Light Mode
- **💾 JSON-Backup** – alle Tabellen als Datei exportieren
- Echtzeit-Sync via Supabase Realtime (Änderungen von zwei Geräten gleichzeitig)
- Git-Auto-Push-Hook: jede Änderung an `index.html` wird automatisch committed & gepusht

---

## Technischer Stack

| Schicht | Technologie |
|---|---|
| Frontend | Vanilla HTML/CSS/JS (kein Framework, kein Build-Step) |
| Hosting | GitHub Pages |
| Datenbank | Supabase Postgres (Projekt `wkqaktxdrtohwzrtpjrh`) |
| Realtime | Supabase Realtime Websocket |

### Datenbank-Tabellen

**`podcast_episodes`**
```
id, title, num, date, recording_date, desc, tasks (jsonb),
notes, transcript, content_plan (jsonb)
```

**`podcast_ideas`**
```
id, title, content, guests, status, drive_link,
questions, core_message, updated_at
```

### Edge Function
`supabase/functions/podcast-ai/index.ts` – nimmt `{ taskId, transcript, epTitle, customPrompt }` entgegen, wählt den passenden Prompt, ruft Claude auf und gibt `{ result }` zurück.

---

## Login & Sicherheit
- Login per E-Mail-Link (Supabase Auth, kein Passwort). Zugriff haben nur E-Mails in der Tabelle `app_users`.
- RLS: Mitglieder-Policies auf allen Tabellen (`supabase/migrations/20261024_phase1a_members.sql`).
- Übergangsphase: anonymer Zugriff ist noch offen, bis Nils und Leo sich erfolgreich angemeldet haben. Danach `20261024_phase1b_drop_anon.sql` ausführen und in `index.html` `AUTH_REQUIRED = true` setzen.
- Gleichzeitiges Bearbeiten: Speichern mit Versionsprüfung (`updated_at`), bei Konflikt 3-Wege-Merge – Änderungen an verschiedenen Feldern gehen nicht verloren.

## Datensicherung & Wiederherstellung
- Automatisch: jeden Montag 03:00 UTC sichert die Edge Function `backup` alle Tabellen als JSON in den privaten Storage-Bucket `backups` (12 Versionen).
- Manuell: 💾-Button in der App lädt alle Tabellen als JSON herunter (gleiches Format).
- Wichtig: Kopien zusätzlich außerhalb von Supabase aufbewahren (z. B. `Desktop/Podcast/PodcastBackups/`), nicht im öffentlichen Repo.
- Wiederherstellen (löscht nie, upsert per ID; erst Probelauf):
  ```bash
  python3 scripts/restore-backup.py backup.json            # Probelauf, zeigt Unterschiede
  SUPABASE_SERVICE_KEY=... python3 scripts/restore-backup.py backup.json --apply
  ```

## Lokale Entwicklung

Kein Build-Step nötig – einfach `index.html` im Browser öffnen.  
Für den Auto-Push-Hook muss Git lokal konfiguriert sein.

```bash
# Repo klonen
git clone https://github.com/<org>/PodcastCheck.git

# Datei direkt im Browser öffnen
open index.html
```

---

## Autoren

**Nils Labitzke & Leo** – Glans & Gloria Podcast
