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

### Workflow-Checkliste (pro Folge)
Aufgaben in einklappbaren Abschnitten:
- **Produktion** – Aufnahme, Schnitt, Mastering, Transkript
- **Plattform-Upload** – Spotify, YouTube, Apple, Notizen
- **Reels** – Download, 8× Einzel-Reels (Transkript + Hook + Thumbnail + Beschreibung + Upload), Haken auf allen Plattformen
- **Social Media** – Karussell-Posts
- **LinkedIn** – 5 Beiträge erstellen & hochladen

Jede Aufgabe: abhakbar, KI-generierbar (✨), Freitext-Notiz.

### Content-Kalender (pro Folge)
- 14-Tage-Plan nach Release mit allen geplanten Posts/Reels/Karussells
- Jedes Item: abhakbar + N/L-Zuweisung (Nils / Leo)
- Fertige LinkedIn- und Reel-Kategorien haken automatisch die übergeordnete Workflow-Aufgabe ab

### KI-Generierung
Alle Generierungen über Supabase Edge Function `podcast-ai` (Claude via Anthropic API):

| Funktion | Beschreibung |
|---|---|
| Titel (Spotify/YouTube) | Aus Transkript generieren |
| Shownotes | Strukturierte Episodenbeschreibung |
| Kapitel | Zeitstempel-Kapitel |
| Thumbnail-Idee | Visuelles Konzept |
| 8 Reel-Transkripte | Splittet Transkript in 8 Clips |
| Reel-Hook, Beschreibung, Thumbnails | Pro Reel einzeln |
| 5 LinkedIn-Beiträge | Split-Generierung, je Beitrag in eigenem Feld |
| Fragen (Ideenpool) | Interviewfragen aus Titel/Thema/Gast |

**Custom-Prompts** für alle KI-Schritte einstellbar unter *Prompt-Einstellungen*.  
**Abschneide-Warnung** wenn der Output am Token-Limit abgeschnitten wurde.

### Offene Aufgaben
- Übersicht aller unerledigten Workflow-Schritte über alle Folgen
- **Content-Kalender-Aufgaben** mit Filter nach Nils / Leo

### Ideenpool
- Folgenideen sammeln: Titel, Themenpunkte, Kernaussage & G&G, Gast, Status
- Status: 💡 Idee → 📩 Gast angefragt → ✅ Bestätigt
- Google-Drive-Link & Fragenkatalog (KI-generierbar) pro Idee
- **„In Planer übernehmen"** – aus einer bestätigten Idee direkt eine neue Folge anlegen (Titel, Beschreibung, Fragenkatalog werden übertragen)

### Sonstiges
- Dark / Light Mode
- **💾 JSON-Backup** – alle Folgen & Ideen als Datei exportieren
- Echtzeit-Sync via Supabase Realtime (Änderungen von zwei Geräten gleichzeitig)
- Git-Auto-Push-Hook: jede Änderung an `index.html` wird automatisch committed & gepusht

---

## Technischer Stack

| Schicht | Technologie |
|---|---|
| Frontend | Vanilla HTML/CSS/JS (kein Framework, kein Build-Step) |
| Hosting | GitHub Pages |
| Datenbank | Supabase Postgres (Projekt `xsxsyfaxhwrbllvvfxxm`) |
| KI | Supabase Edge Function → Anthropic Claude API |
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

## Sicherheitshinweis

Der Supabase Anon-Key ist im Client-Code enthalten (by design für Public-Key-Konzept von Supabase).  
**Solange Row Level Security (RLS) in Supabase deaktiviert ist, sind die Daten mit dem Key lesbar und schreibbar.**  
Empfehlung: RLS aktivieren + einfaches Login einbauen, oder Repo auf privat stellen.

---

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
