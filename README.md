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
- **Nicht gebuchte Zahlungen** aus wiederkehrenden Posten (seit Startdatum) erscheinen oben in der Übersicht mit „Buchen“ / „Alle als bezahlt buchen“ und im Tab „Wiederkehrend“ als „Nachbuchen“. Option **„Wird automatisch abgebucht“** pro Posten (`auto_book`): fällige Zahlungen werden beim Laden automatisch gebucht (Protokoll: „Automatisch“, ohne Duplikate).
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
- **Zielerreichung (Jahresübersicht):** in jedem Jahr dieselben 8 Zeilen in fester Reihenfolge (`STRAT_SUMMARY_ROWS`), jede einzeilig. Ohne Ziel: neutrale Zeile mit „kein Ziel“. Der Messzeitraum steht klein neben dem einheitlichen Namen, das Genaue im Tooltip. Reine Darstellung, die Daten bleiben unverändert; die Karten darunter zeigen weiter die gespeicherten Zieltitel.
- **Meilensteine = allgemeine To-dos** (`podcast_todos.strategy_year`, `strategy_key`) mit Chip „🎯 Strategie JJJJ“ – ein gemeinsamer Erledigt-Status in Aufgaben und Strategie. „Langfolgenschnitt auslagern“ (2028) zeigt die 300-€-Auswertung (Ø der letzten N vollständig erfassten Monate aus Finanzen, Standard 3, einstellbar) und den Status Offen / Bereit zur Umsetzung / Umgesetzt (= To-do erledigt). Keine automatische Beauftragung.

### Investitionen (Strategie)
- Geplante Anschaffungen und Upgrades (`podcast_investments`): Titel, Kategorie, Nutzen, geschätzter Preis, Priorität, Status (Idee/Geplant/Beobachten/Kaufbereit/Gekauft), Zieljahr/-quartal, Kaufbedingung, aktuelle und gewünschte Lösung, Notiz. Karten mit Filtern (Kategorie, Priorität, Status) und Sortierung (Priorität, Preis, zuletzt bearbeitet).
- Kategorien (`podcast_investment_categories`) sind umbenennbar, erweiterbar und archivierbar. „Aktuelles Setup“ (`podcast_setup_items`) wird je Kategorie gezeigt.
- **Finanzen:** Investitionen zählen nie als Ausgabe. Erst „In Finanzen übernehmen“ (bei Status Gekauft) öffnet das normale Buchungsformular; die Buchung trägt `investment_id`, höchstens eine je Investition (Unique-Index). Beim Löschen der Investition bleibt die Buchung bestehen.
- **Aufgaben:** Im Formular lässt sich eine allgemeine Aufgabe anlegen (`podcast_todos.investment_id`, Chip „💼 Investition“). Sie bleibt ein normales To-do und überlebt das Löschen der Investition.
- **Späteres Upgrade-Board:** Die Kategorie ist zugleich der Setup-Bereich. Pro Bereich liegen damit aktuelles Setup (`podcast_setup_items`) und mögliche Upgrades samt Preis und Status vor; es fehlt nur noch die Grafik.

- **Studio-Upgrade** (Tab neben „Übersicht“): isometrisches SVG-Studio aus denselben Datensätzen wie die Liste, ohne eigene Kopien. Bereich einer Zeile = `studio_area`, sonst aus der Kategorie abgeleitet. Solide gezeichnet wird nur, was wirklich da ist (Setup-Eintrag oder Status „Im Einsatz“), alles andere gestrichelt. „Gekauft“ zeigt ein Paket im Raum, die Komponente gilt erst mit „Im Einsatz“ als vorhanden. Jeder Bereich ist auch über die Komponentenliste wählbar.
- **Mein nächstes Setup planen:** Auswahl in `planned_next` (für beide gleich, reine Planung). Summe nur aus bekannten Preisen, z. B. „Bekannte Kosten: 250 € + 1 Upgrade ohne Preis“.
- **Stufen** (Basis-Setup, Creator-Studio, Pro-Studio) sind rein visuell und nennen die zugrunde liegenden Komponenten, keine Qualitätswerte. Die Regel steht in `STUDIO_STAGES`.
- **Finanzen:** Geschätzter und tatsächlicher Preis werden getrennt gezeigt. Gekaufte Investitionen können eine neue Ausgabe anlegen oder mit einer bestehenden Buchung verknüpft werden, nie automatisch und höchstens einmal.

- **Produktlinks** (`podcast_investment_links`): beliebig viele je Investition mit Bezeichnung, URL und optionalem Angebotspreis, im Formular der Investition und im Studio-Detailpanel bearbeitbar, aus denselben Daten. Nur http(s) ohne Zugangsdaten; ohne Schema wird https ergänzt. Links öffnen in einem neuen Tab mit `rel="noopener noreferrer"`. Angebotspreise dienen nur dem Vergleich (günstigstes Angebot, Abstand zur Schätzung) und ändern nie `price_cents`.

### Navigation & Dashboard
- Seitenleiste in Gruppen: Dashboard · **Produktion** (Planer, Kalender) · **Gäste** (Ideen & Akquise, Experten) · **Team** (Aufgaben, Leitfäden & Skills) · **Business** (Strategie, Finanzen).
- Der Zeitstrahl ist die dritte Ansicht im Planer (Raster / Kanban / Zeitstrahl); `#zeitstrahl` funktioniert weiter.
- Dashboard mit vier Kennzahlen: nächste Veröffentlichung, nächste Aufnahme, offene Aufgaben (inkl. überfälliger), fällige Gästeakquise. Die Liste „Gästeakquise“ zeigt überfällige und heute fällige Aktionen sowie Terminabstimmungen; fällige allgemeine Experten-Wiedervorlagen stehen weiter darunter. Überfällige Akquise erscheint auch unter „Handlungsbedarf“.
- Überschriften nutzen Linien-Icons (`icon()`) statt Emojis.

### Persönliches Dashboard (Widgets)
- **„Dashboard anpassen“** startet den Bearbeitungsmodus. Darin lassen sich Widgets verschieben, ausblenden (✕) und vergrößern bzw. verkleinern (Klein / Mittel / Groß, je nach Widget), und über „+ Widget hinzufügen“ kommen neue aus der Bibliothek dazu. „Standardlayout wiederherstellen“ fragt vorher nach. „Fertig“ beendet den Modus.
- **Verschieben:** per Ziehen am Griff ⠿ (Maus, Stift und Touch über Pointer-Events, nur im Bearbeitungsmodus; ein Platzhalter zeigt die Zielposition). Alternativ mit den Buttons ↑/↓ oder den Pfeiltasten auf dem Griff. Die Inhalte sind im Bearbeitungsmodus inaktiv (`inert`), damit beim Ziehen nichts ungewollt angeklickt wird.
- **Bibliothek mit festen Widget-IDs:**
  - Überblick: Handlungsbedarf.
  - Produktion: nächste Veröffentlichung, nächste Aufnahme, aktive Folgen, Produktionsfortschritt, anstehende Produktionsaufgaben.
  - Gäste: Gästeakquise, fällige Follow-ups, Terminabstimmungen.
  - Aufgaben: meine Aufgaben, alle offenen, überfällige, Teamübersicht.
  - Social Media: nächste Posts, Kalender für 7 Tage.
  - Strategie: YouTube- und Spotify-Ziel, Meilensteine, geplante Studio-Upgrades.
  - Finanzen: Einnahmen, Ausgaben und Saldo des Monats, Finanzübersicht.
- **Datenquellen:** Alle Widgets nutzen die bestehenden Datenfunktionen (`dashboardFacts`, `alertsHtml`, `acqAllRows`, `stratActual`, `finSum` …). Fehlt ein Ziel, steht dort „kein Ziel festgelegt“; ein Wert wird nie geschätzt. Finanz-, Strategie- und Investitionsdaten werden nur geladen, wenn ein entsprechendes Widget sichtbar ist.
- **Standardlayout:** Handlungsbedarf, Meine Aufgaben, Gästeakquise, Nächste Veröffentlichungen, Nächste Aufnahmen, Social-Media-Posts, Produktionsfortschritt.
- **Speicherung:** Tabelle `podcast_user_preferences` mit `user_id` (Supabase-Auth-ID aus dem JWT, `sub`), `dashboard_layout` (JSON `{v, widgets:[{id,size}]}`) und `updated_at`.
  - Jede Änderung wird nach kurzer Pause gespeichert. „✓ Gespeichert“ erscheint erst nach Bestätigung durch den Server, ein Fehler wird mit „Erneut speichern“ angezeigt.
  - Beim Öffnen des Dashboards und vor jeder Bearbeitung wird die aktuelle Version geladen, damit ein anderes Gerät nicht überschrieben wird.
  - Unbekannte IDs aus älteren Layouts werden ignoriert, und neue Widgets erscheinen automatisch in der Bibliothek.
- **RLS:** nur `authenticated` und nur die eigene Zeile (`user_id = auth.uid()`), zusätzlich `is_app_user()`. `anon` hat keine Rechte auf die Tabelle.
- **Ohne Anmeldung:** Gespeichert wird nur bei einer geprüften Anmeldung (`app_users`), nie über „Wer bin ich?“, eine Geräte-ID oder localStorage. Ohne Anmeldung erscheint das Standardlayout, und „Dashboard anpassen“ verweist auf die Anmeldung.
- „Meine Aufgaben“ nimmt die Person aus `app_users.name` des angemeldeten Kontos, sonst – nur zur Anzeige – aus „Wer bin ich?“.

### Gästeakquise (Ideen & Akquise)
- Menüpunkt „Ideen & Akquise“ mit den Tabs **Akquise** (Standard beim Öffnen über das Menü) und **Ideen**. Wer eine bestimmte Idee öffnet – aus der Akquise-Liste, einem Expertenprofil, der Suche oder einer Aufgabe –, landet direkt in der Idee und im Tab „Ideen“. Aus der Akquise geöffnet, führt „← Zurück zur Akquise“ zurück.
- Keine eigene Gästetabelle; die bestehenden Strukturen werden erweitert:
  - `podcast_experts`: Stammdaten (+ Telefon, Anrede für E-Mails). Ein Experte existiert nur einmal.
  - `podcast_expert_ideas`: genau eine **Anfrage** je Experte und Idee, mit Rolle (Wunschgast / Alternative 1 / 2 / weitere), tatsächlichem Kontaktstatus, Zuständigkeit, Notizen und ggf. übernommener Folge.
  - `podcast_expert_contacts`: **Kontakt-Timeline**, mit `idea_id` und Ereignistyp (Erstanfrage, Follow-up 1/2, Antwort, Sonstiges, Notiz, Status, Zuständigkeit). Erscheint auch in der Kontaktchronik des Experten; Einträge einer Anfrage sind dort nicht löschbar.
- **Nächste Aktion** wird bei jedem Rendern aus den dokumentierten Daten berechnet, nie gespeichert. Fristen aus `podcast_settings.acq_intervals` (Standard 7/17/24 Tage). Ohne Versanddatum gibt es keine Frist. Ein später versendetes Follow-up verschiebt die nächste Frist: Es zählt das späteste Datum aus allen bekannten Versanddaten mit dem jeweiligen Abstand. Antwort, Interesse, Termin, Zusage, Absage, „Ruhend“ und „Keine weitere Kontaktaufnahme“ beenden die Follow-ups.
- **Warnungen statt Sperren:** bei einer zweiten aktiven Anfrage zur selben Idee und bei mehreren Zusagen (Hinweis in Idee und Übersicht).
- **Direkt in der Akquise bedienbar:**
  - **„+ Anfrage erfassen“** (Hauptbutton im Akquise-Tab) mit Folgenidee (vorhanden oder neu), Experte (vorhandenes Profil suchen oder neu anlegen), E-Mail, Zuständigkeit, Kontaktstatus, frei wählbarem Datum der Erstanfrage (auch rückwirkend; leer = unbekannt → „Versanddatum ergänzen“) und Notiz.
  - Doppelte Anfragen (gleicher Experte und gleiche Idee) werden verhindert. Eine bereits angelegte Idee oder ein neues Profil wird bei einem erneuten Versuch nicht noch einmal angelegt.
  - Jede Anfrage ist eine **aufklappbare Karte**. Eingeklappt: Experte, Idee, Status, Zuständigkeit, letzter Kontakt, nächste Aktion und Fälligkeit. Aufgeklappt:
    - **Versand-Checkliste** (Erstanfrage, Follow-up 1, Follow-up 2) mit Fälligkeit („heute fällig“, „seit X Tagen überfällig“, „fällig am …“);
    - Kontaktstatus, Zuständigkeit (Nils / Leo / –), Rolle, Kontaktnotizen, E-Mail-Vorlage, „Antwort / Kontakt dokumentieren“ und die Kontakt-Timeline.
  - Die Karte im Ideen-Dialog ist dieselbe. Expertenprofil, Dashboard und Aufgaben öffnen die Karte direkt in der Akquise.
  - **Abhaken:** Ein Klick auf die Checkbox öffnet ein Datumsfeld (heute vorbelegt, änderbar). Erst nach erfolgreichem Speichern ist der Haken gesetzt; er bleibt dauerhaft und lässt sich nicht überschreiben. Unplausible Daten werden abgelehnt: in der Zukunft, ein Follow-up vor der Erstanfrage oder vor Follow-up 1.
  - **Fristen:**
    - Follow-up 1 = Erstanfrage + 7 Tage.
    - Follow-up 2 = Erstanfrage + 17 Tage, mindestens aber 10 Tage nach dem tatsächlichen Follow-up 1.
    - „Gastalternative prüfen“ = Erstanfrage + 24 Tage, mindestens 17 Tage nach Follow-up 1 bzw. 7 Tage nach Follow-up 2.
    - Bis dahin steht „Antwort ausstehend“.
  - Kennzahlen: Aktive Anfragen, Heute fällig, Überfällig, Terminabstimmungen, Zusagen. Die Liste ist nach Dringlichkeit sortiert, überfällige Follow-ups zuerst.
- **E-Mail-Vorlagen** (`podcast_settings.acq_templates`, im Akquise-Tab bearbeitbar) mit Platzhaltern. Kopieren und Mailprogramm dokumentieren nichts; erst „Als versendet markieren“ mit tatsächlichem Datum.
- **Statistik:** nur Anfragen mit datierter Erstanfrage im Nenner; Anfragen ohne Datum werden ausgewiesen.
- **Aufgaben:** „Als Aufgabe übernehmen“ legt höchstens eine offene allgemeine Aufgabe je Anfrage an (`podcast_todos.acq_request_id`, Unique-Index). Erledigen der Aufgabe dokumentiert keinen Versand.
- **Planer:** Ein zugesagter Gast wird mit Name, Kontakt und Profil-Verknüpfung in eine **neue** Folge übernommen; bestehende Folgen werden nicht überschrieben.
- **Altdaten:** Gast-Freitexte bleiben unverändert. Automatisch verknüpft wurde nur bei eindeutig gleichnamigem Profil (derzeit keins). Sonst „Als Wunschgast übernehmen“ in der Idee: Name, Titel und E-Mail werden vorgeschlagen, „Gast angefragt“ wird zu „Anfrage versendet“ ohne Datum.
- Der Leitfaden „Gästeakquise – Standardprozess“ (Leitfäden & Skills) ist aus der Idee und der Akquise-Übersicht aufrufbar.

### Leitfäden & Skills
- Menüpunkt „Leitfäden & Skills“ mit den Tabs „Produktionsleitfäden“ (unverändert) und „Skills“.
- **Skills** (`podcast_skills`): Name, Zweck, Kategorie, aktuelle Version, Status (Idee bis Archiviert), Verantwortlich (Nils/Leo/gemeinsam), Link (nur http/https), Datei, Notizen. Skills werden archiviert, nicht gelöscht. Die Startstruktur (8 Einträge, Status „Idee“) ist nur ein Vorschlag zur Bestandsaufnahme.
- **Versionen** (`podcast_skill_versions`) bleiben als Verlauf erhalten, die Nummer ist je Skill eindeutig. Eine neue, höhere Nummer wird zur aktuellen Version, ältere lassen sich nachtragen.
- **Geplante Optimierungen** (`podcast_skill_optimizations`): Titel, Beschreibung, Priorität, Status (Offen/In Arbeit/Umgesetzt), Verantwortlich, Umsetzungsdatum. Umgesetzte bleiben sichtbar.
- **Aufgaben:** Pro Optimierung höchstens eine allgemeine Aufgabe, neu angelegt oder verknüpft (Unique-Index auf `todo_id`). Der Status wird in der Datenbank per Trigger in beide Richtungen abgeglichen. Lösen der Verknüpfung lässt die Aufgabe bestehen.
- **Dateien** liegen im privaten Bucket `skills` (nur angemeldete Mitglieder, max. 20 MB) und werden vom Backup nach `backups/skills/` gespiegelt.
- Nur Dokumentation: Die App führt keine Skills aus und ändert sie nicht.

### Neue Aufgaben (blauer Punkt)
- Legt die andere Person eine allgemeine Aufgabe an, erscheint neben „Aufgaben“ (Seitenleiste und Tab-Leiste) ein blauer Punkt. Eigene Aufgaben, Unteraufgaben, erledigte Aufgaben und Produktionsschritte von Folgen lösen keinen Punkt aus.
- Öffnen der Seite entfernt den Punkt in der Navigation; die neuen Aufgaben tragen dann selbst einen Punkt, bis man sie anklickt oder die Seite verlässt.
- Gesehen-Stand je Person in `podcast_settings` (`tasks_seen_nils`, `tasks_seen_leo`), also geräteübergreifend; Ersteller in `podcast_todos.created_by`. Dafür muss das Gerät wissen, wer es nutzt (Anmeldung oder einmalige Abfrage „Wer bin ich?“).

### Ideenpool
- Titel, Themenpunkte, Kernaussage, Gast, Status (Idee → Gast angefragt → Bestätigt), Drive-Link, Fragenkatalog.
- „In Planer übernehmen“ legt aus einer Idee eine Folge an.
- **Priorität** (`podcast_ideas.priority`: high/medium/low, bestehende Ideen = Mittel) mit farbigem Label; Filter und Sortierung (Priorität – Standard, Status, zuletzt bearbeitet) oberhalb der Liste, gemerkt pro Gerät (`gg_idea_ui`). Innerhalb einer Prioritätsstufe bleibt die bisherige Reihenfolge (Status, dann zuletzt bearbeitet).
- **E-Mail des Experten** (optional) mit Kopieren und „E-Mail schreiben“ (mailto). Ist genau ein Expertenprofil verknüpft, ist dessen `podcast_experts.email` die zentrale Adresse: Das Feld zeigt sie, Änderungen werden dort gespeichert, Leeren löscht sie nicht. Ohne Profil liegt die Adresse in `podcast_ideas.guest_email`; „Als Expertenprofil übernehmen“ legt ein Profil an bzw. verknüpft ein gleichnamiges bestehendes (keine Duplikate). `guest_email` bleibt dabei erhalten.
- Beim Übernehmen in den Planer kommen Gast + E-Mail und eine abweichende Priorität in die Beschreibung; verknüpfte Experten werden auch mit der neuen Folge verknüpft.

### Social-Media-Kalender
- Jede Postkarte (zentraler Kalender und Kalender in der Folge) hat unter dem Veröffentlichungs-Häkchen ein gleich großes Kästchen für die Zuständigkeit: N (Nils), L (Leo), – (offen), gespeichert in `podcast_posts.assignee`. Klick öffnet ein Menü. Zuständigkeit und Veröffentlichung sind unabhängig. Eine Zuweisung greift nur, wenn sie noch dem angezeigten Stand entspricht, sonst kommt ein Hinweis.
- Beim Abhaken werden `published_at` und `published_by` gespeichert (Tooltip und Post-Editor), beim Zurücknehmen geleert. Alte Posts bleiben „nicht erfasst“, es wird nichts nachgetragen.
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
| `20261027_fin_recurring_auto_book.sql` | Option „automatisch abgebucht“ für wiederkehrende Posten | angewendet |
| `20261027_idea_priority_email.sql` | Ideen: Priorität (Standard Mittel) und E-Mail des Experten | angewendet |
| `20261102_todo_new_markers.sql` | Aufgaben: `created_by` und Gesehen-Stand je Person (blauer Punkt) | angewendet |
| `20261104_investments.sql` | Strategie: Investitionen, Kategorien, aktuelles Setup; `investment_id` an Buchungen und To-dos | angewendet |
| `20261104_studio_upgrade.sql` | Investitionen Phase 2: `studio_area`, `planned_next`, Status „Im Einsatz“ | angewendet |
| `20261104_investment_links.sql` | Produktlinks je Investition (`podcast_investment_links`) | angewendet |
| `20261108_guest_acquisition.sql` | Gästeakquise: Spalten an Experten, Ideen, `podcast_expert_ideas` (Anfrage) und `podcast_expert_contacts` (Timeline), `podcast_todos.acq_request_id`, Einstellungen, Leitfaden „Gästeakquise – Standardprozess“ v1.0 | angewendet |
| `20261109_user_preferences.sql` | Persönliche Einstellungen je Supabase-Auth-Nutzer (`podcast_user_preferences`, Dashboard-Layout); RLS: nur eigene Zeile und nur Mitglieder, kein `anon` | angewendet |
| `20261108_skills.sql` | Skills: `podcast_skills`, `podcast_skill_versions`, `podcast_skill_optimizations`, Status-Abgleich mit To-dos (Trigger), Bucket `skills` | angewendet |
| `20261104_post_published_by.sql` | Posts: `published_by`; `published_at` wird nur noch beim Wechsel auf „Veröffentlicht“ gesetzt | angewendet |

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
