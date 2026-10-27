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
| **Strategie** | Wachstums-, Produktions- und Finanzziele 2026–2028, Meilensteine, Verbesserungsoptionen |
| **Finanzen** | Buchungen, wiederkehrende Posten, Monats-/Jahresübersicht, Diagramme, Belege, CSV |

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
- Folgen-Infos: Gast, verknüpfte Experten, Freigaben (Folge, Reels, Cover, Social-Posts), Notizen. Transkript und die allgemeinen Linkfelder wurden aus der Oberfläche entfernt; bereits gespeicherte Werte (`transcript`, `links`) bleiben in der Datenbank erhalten. Links in einzelnen Schritten (z. B. Fragenkatalog) bleiben.
- **8 Reels** (Social Media → „8 Reels produzieren“): je Reel ein aufklappbarer Bereich mit Fortschritt („x/4 Texte vorhanden“) und vier Textfeldern – Hook-Ideen, Instagram-, YouTube-Shorts- und TikTok-Beschreibung – jeweils mit Autospeichern und „Kopieren“ (Zeilenumbrüche bleiben erhalten). Gespeichert in den bestehenden Feldern `tasks.reels_download.reels[i].hook/descIg/descYt/descTiktok`; ältere Felder (`transcript`, `desc`, `text`) bleiben unangetastet.
- Reel-Produktion und -Veröffentlichung sind getrennt: Häkchen = „Produktion abgeschlossen“ (bestätigt den Reel-Leitfaden), IG / YT / TikTok = auf der Plattform veröffentlicht (`ig`, `yt`, `tiktok`). Alle drei Plattformen ⇔ Kalender-Post „Reel N“ veröffentlicht; wird der Post im Kalender zurückgesetzt, werden die Plattform-Häkchen zurückgesetzt.
- Workflow-Checkliste (Produktion, Plattform-Upload, Social Media, LinkedIn): je Schritt Zuständigkeit, Deadline, Status, Link, Beschreibung, Inhalt, Erledigt-Datum.

### Leitfäden (SOPs) & Produktionsleitlinien
- Verbindliche Produktionsstandards (v1.0): **Allgemeine Bildgestaltung**, **Videobearbeitung der Podcastfolge**, **Plattform-Upload**, **Reels und Shorts** (Kategorie „Produktionsstandards“).
- Zuordnung: „Folge schneiden & exportieren“ → Bildgestaltung + Videobearbeitung · „Hook … + Musik“ → Abschnitte *Hook und Übergänge* / *Intro und Musik* der Videobearbeitung · „Shownotes“ → *Folgenbeschreibung* · „Kapitel“ → *Kapitel und Keywords* · „Upload“ → ganzer Upload-Leitfaden · jedes einzelne Reel → Reels und Shorts + Bildgestaltung.
- In der Aufgabe erscheinen die Vorgaben als **lesbare Checkliste ohne einzelne Häkchen**. Ein einziges Abhaken des Schritts (bzw. jedes Reels einzeln) bestätigt die Einhaltung – Hinweis: „Mit dem Abhaken bestätigst du, dass der zugehörige Produktionsleitfaden eingehalten wurde.“ Kein zusätzlicher Dialog.
- Gespeichert wird `sopConfirmation = {by, byEmail, at, guides:[{id, version, title, sections}]}` im jeweiligen Schritt (`tasks.<schritt>`) bzw. pro Reel (`tasks.reels_download.reels[i]`). Wieder öffnen hebt die Bestätigung auf.
- Wer bestätigt: angemeldetes Mitglied, sonst die einmal pro Gerät gewählte Person („Wer bin ich?“ in der Seitenleiste).
- „Alle abhaken“ und automatische Abschlüsse bestätigen keine Leitfäden – solche Schritte müssen einzeln abgehakt werden. „8 Reels vorbereiten“ wird automatisch erledigt, sobald alle 8 Reels abgehakt sind.
- Bereits erledigte Schritte bleiben unverändert; für sie wird keine Bestätigung nachträglich erzeugt („Abgeschlossen vor Einführung des Leitfadens“).
- Zentrale Bearbeitung unter „Leitfäden“: Vorgaben mit Überschriften gliedern, einem Leitfaden mehrere Schritte zuordnen und pro Schritt einzelne Abschnitte wählen (`step_sections`), mehrere Leitfäden pro Schritt möglich.
- Versionierung: Entwurf → „Freigeben“ erzeugt eine unveränderliche Version (`podcast_guide_versions`). Offene Schritte zeigen immer die aktuelle Version, bestätigte Schritte den Stand zum Zeitpunkt der Bestätigung.

### Aufgaben
- Eingang „Nicht zugewiesen“ → an Leo oder Nils verteilen; Spalten Leo / Nils mit einklappbaren erledigten Aufgaben.
- Felder: Titel, Beschreibung, Verantwortlich, Priorität, Deadline, Status, Projekt/Kategorie (`podcast_task_projects`), Unteraufgaben.
- Ansichten: **Allgemeine To-dos** (nur unabhängige Podcast-Aufgaben aus `podcast_todos` ohne `episode_id`) · **Folgenaufgaben** (Produktionsschritte direkt aus den Folgen, keine Kopien; Klick führt zum Schritt in der Folge) · **Alle Aufgaben** (beide Typen inkl. Posts und Follow-ups, jeweils mit Kennzeichnung „Allgemein“ / „Folge“).
- Filter und Zähler beziehen sich immer nur auf den gewählten Tab.
- Aufgabentyp dauerhaft über `podcast_todos.episode_id` / `step_id`: Zeilen mit `episode_id` verweisen auf einen Produktionsschritt (maßgeblich ist die Folge) und werden nicht als Aufgaben gelistet. Die 13 früheren Kopien „Lernmethoden (26.10.2026): …“ sind so ihrem Schritt zugeordnet und bleiben erhalten.
- Filter: Alle, Nils, Leo, Nicht zugewiesen, Überfällig, Diese Woche, Erledigt.
- Standard-Fälligkeit von Folgenaufgaben: Produktion/Upload bis Release, Social Media/LinkedIn bis Release + 13 Tage.

### Experten (CRM)
- Profil: Name, Titel, Fachgebiet, Spezialisierung, Klinik/Uni, E-Mail, Website, Social Media, Drive-Link, Notizen, Zuständigkeit.
- Status: Wunschgast → Recherche → Anfrage vorbereiten → Anfrage versendet → Rückmeldung → Zusage → Termin → Aufnahme → Folge veröffentlicht (bzw. Abgesagt / Zurückgestellt).
- Kontaktchronik mit nächster Wiedervorlage; automatisches Follow-up bei „Anfrage versendet“ ohne Antwort nach N Tagen (Standard 10, einstellbar).
- Verknüpfung mit Ideen und Folgen; Freitext-Gastnamen bleiben erhalten, passende Experten werden nur vorgeschlagen.

### Finanzen
Interne Finanzübersicht (ersetzt keine steuerliche Buchhaltung, keine steuerlichen Bewertungen).
- **Zwei getrennte Sichten:** *Buchungen* = tatsächlicher Geldfluss (nur Status „bezahlt“ zählt) · *Wiederkehrende Posten* = Planung (rechnerischer Monatsbetrag, z. B. 120 € jährlich = 10 €/Monat). Aus Planposten entstehen nie automatisch Buchungen.
- **Oben:** Jahresauswahl, KPIs (Einnahmen, Ausgaben, Saldo, Ø Einnahmen/Monat – nur aus „vollständig erfassten“ Monaten –, Fixkosten/Monat als Planwert), „+ Einnahme“ / „+ Ausgabe“, CSV-Export (Jahr, nur Einnahmen, nur Ausgaben, Monat, aktuelle Filterauswahl/Kategorie). Auch über den Plus-Button erreichbar.
- **Übersicht:** gruppiertes Balkendiagramm Einnahmen vs. Ausgaben, Umsatzentwicklung (pro Monat / kumuliert / Saldo-Verlauf), Donuts Einnahmequellen und Ausgabenkategorien, Karte „Monatliche Fixkosten“ (Liste, pro Jahr, nächste Fälligkeiten, Differenz zu regelmäßigen Einnahmen). Diagramme sind schlanke SVGs ohne Bibliothek, mit Tooltips, Tastaturbedienung, Dark/Light und farbenblind-geprüfter Palette.
- **Wiederkehrend:** Einnahmen/Ausgaben mit Betrag pro Intervall (monatlich, quartalsweise, halbjährlich, jährlich), Monatsbetrag, nächster Zahlung, Status; Summen und rechnerischer Überschuss. Fällige Zahlungen werden vorgeschlagen („Als bezahlt erfassen“) – doppelte Buchungen pro Zeitraum verhindert die Datenbank (`unique(recurring_id, period_key)`).
- **Monate:** Jan–Dez mit Einnahmen, Ausgaben, Saldo, Fixkosten (Plan); Detailansicht mit Einzelbuchungen, Buchung hinzufügen, CSV und „Monat vollständig erfasst“ (nicht für zukünftige Monate).
- **„+ Einnahme“ / „+ Ausgabe“ mit „Wiederholung“** (einmalig, monatlich, quartalsweise, halbjährlich, jährlich): legt bei Wiederholung zugleich den wiederkehrenden Posten an; liegt die erste Zahlung in der Vergangenheit, können alle bisherigen Zahlungen per Häkchen als bezahlt gebucht werden (je Zeitraum nur einmal). Dasselbe Häkchen gibt es beim Anlegen unter „Wiederkehrend“.
- **Buchungen:** Suche, Filter (Art, einmalig/wiederkehrend, Kategorie, Status), Bearbeiten, Löschen, Umkategorisieren, Belege, Bezug zu Folge/Kooperation. Kategorien ergänzbar/umbenennbar/archivierbar. Ältere Daten aus dem früheren Finanz-Reiter werden angezeigt und nur per Klick übernommen.
- **Protokoll:** Jede neue, geänderte und gelöschte Buchung wird per Datenbank-Trigger in `podcast_fin_booking_log` festgehalten (für Clients nur lesbar).
- **Belege:** privater Storage-Bucket `receipts`, Zugriff nur für angemeldete Mitglieder (`is_app_user()`), Öffnen über kurzlebige signierte Links. Das wöchentliche Backup spiegelt Belege nach `backups/receipts/`.
- Tabellen: `podcast_fin_categories`, `podcast_fin_recurring`, `podcast_fin_bookings`, `podcast_fin_months`, `podcast_fin_booking_log` (Beträge in Cent).

### Strategie
- Jahresauswahl **2026 | 2027 | 2028**; pro Jahr „Zielerreichung“ (Ist vs. Ziel vs. Bonus für alle Kennzahlen) und Gruppen: **Reichweite & Community**, **Podcast-Performance**, **Finanzielle Ziele**, **Strategische Meilensteine**. Darunter „Weitere Ziele“ (bisherige freie Ziele) und die Verbesserungsoptionen.
- Jede Zielkarte: Kennzahl, Ist-Wert, Ziel, Bonus, Fortschrittsbalken, Messzeitraum, Stand/Datum, Hinweise. Verlauf als Mini-Linie, sobald mindestens zwei echte Messwerte vorliegen.
- **Ist-Werte – je eine Quelle:**
  - Follower/Abonnenten: „Ist-Wert erfassen“ (Wert + Messdatum) → `podcast_metric_values`; gilt plattformweit für alle Jahre.
  - Spotify-Plays: ein Wert pro Monat (erneutes Speichern ersetzt); 2026 = Ø November + Dezember (erst mit beiden Monaten), 2027/2028 = Jahressumme.
  - Veröffentlichte Folgen: automatisch aus dem Planer (Status „Veröffentlicht“ und Datum erreicht) im Messzeitraum.
  - Finanzen: automatisch aus bezahlten Einnahmen in „Finanzen“; Klick auf die Karte öffnet die Finanzübersicht des Jahres.
- Zielerreichung nur bei Messwerten **innerhalb** des Messzeitraums; Referenz- und geplante Startwerte sind reine Hinweise und zählen nie als Ist-Wert.
- Ziel-/Bonuswerte nur über „Ziel bearbeiten“ (`podcast_strategy_goals`, Finanzziele in `podcast_revenue_goals`).
- **Meilensteine = allgemeine To-dos** (`podcast_todos.strategy_year`, `strategy_key`) mit Chip „🎯 Strategie JJJJ“ – ein gemeinsamer Erledigt-Status in Aufgaben und Strategie. „Langfolgenschnitt auslagern“ (2028) zeigt die 300-€-Auswertung (Ø der letzten N vollständig erfassten Monate aus Finanzen, Standard 3, einstellbar) und den Status Offen / Bereit zur Umsetzung / Umgesetzt (= To-do erledigt). Keine automatische Beauftragung.

### Ideenpool
- Titel, Themenpunkte, Kernaussage, Gast, Status (Idee → Gast angefragt → Bestätigt), Drive-Link, Fragenkatalog.
- „In Planer übernehmen“ legt aus einer Idee eine Folge an.

### Social-Media-Kalender
- Posts (`podcast_posts`): Folge, Format, Plattformen, Datum, Uhrzeit, Zuständigkeit, Titel, Beschreibung, Medien-/Veröffentlichungslink, Status.
- Standardvorlage: 8 Reels, 3 Instagram-Karussells, 2 YouTube-Clips (Sonntag Woche 1 ~10:00, Donnerstag Woche 2 ~16:00) über 14 Tage ab Release sowie 2 LinkedIn-Beiträge am 1. und 2. Dienstag nach dem Release um 07:45
- Vorlagen-Titel wie „Reel 3“ werden in den Kalender-Kacheln nicht wiederholt – das Format-Symbol reicht – automatisch für neue Folgen, für bestehende per „Standardvorlage anwenden“ ohne Duplikate (`template_key`).
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
| Edge Functions | `backup` (wöchentliches JSON-Backup inkl. Beleg-Spiegelung), `calendar-ics` (ICS-Feed) |

### Tabellen
`podcast_episodes`, `podcast_ideas`, `podcast_todos`, `podcast_task_projects`, `podcast_guides`, `podcast_guide_versions`,
`podcast_experts`, `podcast_expert_contacts`, `podcast_expert_ideas`, `podcast_expert_episodes`, `podcast_posts`,
`podcast_events`, `podcast_calendar_feeds`, `podcast_settings`, `podcast_goals`, `podcast_improvements`, `podcast_revenue_entries`, `podcast_revenue_corrections`, `podcast_revenue_months`, `podcast_revenue_goals`, `podcast_fin_categories`, `podcast_fin_recurring`, `podcast_fin_bookings`, `podcast_fin_months`, `podcast_fin_booking_log`, `podcast_strategy_goals`, `podcast_metric_values`, `app_users`.
Nicht mehr in der App genutzt, aber unverändert erhalten: `podcast_prompts`, `podcast_revenue_entries`, `podcast_revenue_corrections`, `podcast_revenue_months`; `podcast_expenses`, `podcast_income`, `podcast_settlements` (alte Finanzdaten – in „Finanzen → Buchungen“ einsehbar und einzeln übernehmbar).

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
| `20261027_ytclips.sql` | Format `ytclip` + 2 YT-Clips für kommende Folgen | angewendet |
| `20261027_sop_production_standards.sql` | `podcast_guides.step_sections` + 4 Produktionsleitlinien v1.0 | angewendet |
| `20261027_todo_task_type.sql` | `podcast_todos.episode_id/step_id`, 13 Folgen-Kopien zugeordnet | angewendet |
| `20261027_revenue.sql` | Einnahmen: Monatswerte, Korrekturen, Bestätigung, Ziele 2026–2028, 300-€-Regel | angewendet |
| `20261027_finance.sql` | Finanzmodul: Kategorien, wiederkehrende Posten, Buchungen, Monatsstatus, Änderungsprotokoll, Beleg-Bucket | angewendet |
| `20261027_strategy_goals.sql` | Wachstumsziele 2026–2028, Messwerte, Meilensteine als To-dos | angewendet |

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
