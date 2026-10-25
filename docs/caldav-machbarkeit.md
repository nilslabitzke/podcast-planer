# iCloud-CalDAV: Machbarkeit einer Zwei-Wege-Synchronisierung

Stand: Phase 7 (25.10.2026). Umgesetzt ist **nur** das schreibgeschützte ICS-Abonnement
(`supabase/functions/calendar-ics`). Dieses Dokument bewertet die zweite Ausbaustufe;
eine Implementierung erfolgt erst nach ausdrücklicher Freigabe.

## Ergebnis

Technisch machbar mit den vorhandenen Mitteln (Supabase Edge Functions + pg_cron + Vault),
ohne kostenpflichtige Dienste – aber mit spürbarem Aufwand und einem echten Sicherheitsrisiko,
weil Apple-Zugangsdaten serverseitig gespeichert werden müssen.

## Wie es funktionieren würde

1. **Zugang:** Apple bietet für iCloud-Kalender kein OAuth. Jede Person erzeugt unter
   appleid.apple.com ein **app-spezifisches Passwort**. Dieses wird einmalig in der App
   eingegeben, sofort an eine Edge Function übergeben und verschlüsselt in **Supabase Vault**
   abgelegt – nie im Browser gespeichert, nie zurückgegeben. Widerruf jederzeit bei Apple.
2. **Kalenderauswahl:** Discovery über `https://caldav.icloud.com` (PROPFIND auf
   `current-user-principal` → `calendar-home-set`) liefert die Kalender der Person; sie wählt
   einen aus oder lässt den Kalender „Glans & Gloria“ anlegen (MKCALENDAR).
3. **App → Kalender:** Bei Änderungen (DB-Trigger/Realtime oder Cron alle 5 min) schreibt die
   Edge Function Termine per `PUT` mit stabiler UID (wie im ICS-Feed) und `If-Match`-ETag.
4. **Kalender → App:** Cron-Abfrage per `REPORT sync-collection` (Sync-Token) liefert nur
   geänderte/gelöschte Termine. Änderungen an Datum/Uhrzeit werden auf die zugehörigen
   Objekte (Folge, Post, Termin) zurückgeschrieben; unbekannte Termine werden ignoriert.
5. **Konflikte:** Pro Termin werden ETag und `updated_at` der App gespeichert
   (Mapping-Tabelle `calendar_sync_items`). Haben sich beide Seiten seit dem letzten Abgleich
   geändert, gewinnt nicht still eine Seite – der Konflikt erscheint in der App zur Entscheidung.
6. **Duplikate:** Ausgeschlossen durch die stabile UID je Objekt und die Mapping-Tabelle.
7. **Private Daten:** Es werden nur Termine im gewählten Podcast-Kalender gelesen/geschrieben;
   andere Kalender der Person werden nie abgefragt.

## Risiken und offene Punkte

- **Zugangsdaten:** Ein app-spezifisches Passwort erlaubt Zugriff auf *alle* iCloud-Kalender
  und -Kontakte der Person. Ein Leck der Supabase-Instanz wäre gravierend. Gegenmaßnahmen:
  Vault, strikte RLS, getrennte Edge Function, Protokollierung.
- **Inoffizielle Schnittstelle:** CalDAV bei iCloud ist stabil, aber von Apple nicht
  dokumentiert; Rate-Limits und Fehlerbilder sind nicht garantiert.
- **Was ist „zurück übertragbar“?** Sinnvoll sind Datum/Uhrzeit von Aufnahmen, Posts und
  eigenen Terminen. Releases folgen dem 2-Wochen-Rhythmus des Planers – deren Verschieben
  im Kalender sollte eher als Hinweis statt automatisch übernommen werden.
- **Aufwand:** grob 3–5 Entwicklungstage inkl. Tests (Discovery, Sync-Token, Konfliktansicht,
  Fehlerbehandlung, Widerruf).

## Empfehlung

Zunächst das ICS-Abo im Alltag nutzen. Falls echte Zwei-Wege-Bearbeitung gebraucht wird,
CalDAV mit eng begrenztem Umfang starten: nur eigene Termine und Aufnahmetermine
bidirektional, alles andere weiterhin einseitig.
