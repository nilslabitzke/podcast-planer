import "jsr:@supabase/functions-js/edge-runtime.d.ts";

// Read-only iCalendar (ICS) subscription feed for "Glans & Gloria".
// Access only via a revocable token (podcast_calendar_feeds); data is read with the
// service role on the server, nothing privileged reaches the calendar client.
// This is a one-way subscription, not a two-way sync.

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SERVICE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const APP_URL = 'https://nilslabitzke.github.io/podcast-planer/';
const TZ = 'Europe/Berlin';
const H = { apikey: SERVICE_KEY, Authorization: 'Bearer ' + SERVICE_KEY };

const STEP_LABELS: Record<string, string> = {
  fragenerstellung: 'Fragenerstellung', aufnahme: 'Aufnahme über Riverside', hook: 'Hook erstellen',
  schnitt: 'Folge schneiden & exportieren', titel_spotify: 'Spotify-Titel', titel_youtube: 'YouTube-Titel',
  shownotes: 'Shownotes', kapitel: 'Kapitel', upload: 'Upload Spotify/YouTube/Apple', thumbnail_ai: 'Thumbnail/Cover',
  cover_canva: 'Quadratisches Cover', reels_download: '8 Reels vorbereiten', sm1_karussell: 'Woche 1 – Karussell',
  sm1_reels: 'Woche 1 – Reels', sm2_karussell: 'Woche 2 – Karussell', sm2_reels: 'Woche 2 – Reels',
  li_beitraege: 'LinkedIn-Beiträge',
};
const FORMAT_LABELS: Record<string, string> = {
  reel: '🎬 Reel', carousel: '🖼️ Karussell', story: '⭕ Story', linkedin: '💼 LinkedIn', ytclip: '📺 YT-Clip', short: '▶️ Short',
  community: '💬 Community', post: '📝 Beitrag', other: '• Post',
};

async function rest(path: string) {
  const r = await fetch(`${SUPABASE_URL}/rest/v1/${path}`, { headers: H });
  if (!r.ok) throw new Error(`${path}: ${r.status}`);
  return r.json();
}

// ── iCalendar helpers ───────────────────────────────────────────
function escapeText(s: string) {
  return String(s ?? '').replace(/\\/g, '\\\\').replace(/;/g, '\\;').replace(/,/g, '\\,').replace(/\r?\n/g, '\\n');
}
// Fold lines to max. 75 octets without splitting UTF-8 characters (RFC 5545 §3.1).
function fold(line: string) {
  const enc = new TextEncoder();
  if (enc.encode(line).length <= 75) return line;
  const parts: string[] = [];
  let cur = '';
  let curLen = 0;
  for (const ch of line) {
    const n = enc.encode(ch).length;
    const limit = parts.length ? 74 : 75; // continuation lines start with a space
    if (curLen + n > limit) { parts.push(cur); cur = ''; curLen = 0; }
    cur += ch; curLen += n;
  }
  parts.push(cur);
  return parts.join('\r\n ');
}
const pad = (n: number) => String(n).padStart(2, '0');
function utcStamp(d: Date) {
  return `${d.getUTCFullYear()}${pad(d.getUTCMonth() + 1)}${pad(d.getUTCDate())}T${pad(d.getUTCHours())}${pad(d.getUTCMinutes())}${pad(d.getUTCSeconds())}Z`;
}
// Local (Europe/Berlin) wall-clock values handled as naive dates.
type Local = { y: number; m: number; d: number; hh?: number; mm?: number };
function parseDe(s: string | null): Local | null {           // "TT.MM.JJJJ" or "TT.MM.JJJJ HH:MM"
  const m = /^(\d{1,2})\.(\d{1,2})\.(\d{4})(?:\s+(\d{1,2}):(\d{2}))?/.exec(String(s ?? '').trim());
  if (!m) return null;
  return { y: +m[3], m: +m[2], d: +m[1], ...(m[4] ? { hh: +m[4], mm: +m[5] } : {}) };
}
function parseIso(s: string | null, time?: string | null): Local | null {  // "YYYY-MM-DD" + optional "HH:MM"
  const m = /^(\d{4})-(\d{2})-(\d{2})/.exec(String(s ?? ''));
  if (!m) return null;
  const t = /^(\d{1,2}):(\d{2})$/.exec(String(time ?? '').trim());
  return { y: +m[1], m: +m[2], d: +m[3], ...(t ? { hh: +t[1], mm: +t[2] } : {}) };
}
function addMinutes(l: Local, minutes: number): Local {
  const t = new Date(Date.UTC(l.y, l.m - 1, l.d, l.hh ?? 0, l.mm ?? 0) + minutes * 60000);
  return { y: t.getUTCFullYear(), m: t.getUTCMonth() + 1, d: t.getUTCDate(), hh: t.getUTCHours(), mm: t.getUTCMinutes() };
}
const dateVal = (l: Local) => `${l.y}${pad(l.m)}${pad(l.d)}`;
const dateTimeVal = (l: Local) => `${dateVal(l)}T${pad(l.hh ?? 0)}${pad(l.mm ?? 0)}00`;
function toTime(l: Local) { return Date.UTC(l.y, l.m - 1, l.d); }
// SEQUENCE must never decrease: seconds since 2026 of the object's last change.
function sequence(updatedAt?: string | null) {
  const t = updatedAt ? Date.parse(updatedAt) : NaN;
  return isNaN(t) ? 0 : Math.max(0, Math.floor((t - Date.UTC(2026, 0, 1)) / 1000));
}

type Ev = {
  uid: string; summary: string; start: Local; minutes?: number; allDay?: boolean;
  description?: string; url?: string; location?: string; categories?: string; updatedAt?: string | null; busy?: boolean;
};
function vevent(e: Ev, now: Date) {
  const lines = ['BEGIN:VEVENT', `UID:${e.uid}@glans-gloria`, `DTSTAMP:${utcStamp(now)}`];
  if (e.updatedAt) lines.push(`LAST-MODIFIED:${utcStamp(new Date(e.updatedAt))}`);
  lines.push(`SEQUENCE:${sequence(e.updatedAt)}`);
  if (e.allDay || e.start.hh === undefined) {
    const next = addMinutes({ ...e.start, hh: 0, mm: 0 }, 24 * 60);
    lines.push(`DTSTART;VALUE=DATE:${dateVal(e.start)}`, `DTEND;VALUE=DATE:${dateVal(next)}`);
  } else {
    lines.push(`DTSTART;TZID=${TZ}:${dateTimeVal(e.start)}`, `DTEND;TZID=${TZ}:${dateTimeVal(addMinutes(e.start, e.minutes ?? 60))}`);
  }
  lines.push(`SUMMARY:${escapeText(e.summary)}`);
  if (e.description) lines.push(`DESCRIPTION:${escapeText(e.description)}`);
  if (e.location) lines.push(`LOCATION:${escapeText(e.location)}`);
  if (e.url) lines.push(`URL:${e.url}`);
  if (e.categories) lines.push(`CATEGORIES:${escapeText(e.categories)}`);
  lines.push(`TRANSP:${e.busy ? 'OPAQUE' : 'TRANSPARENT'}`, 'END:VEVENT');
  return lines;
}
const VTIMEZONE = [
  'BEGIN:VTIMEZONE', `TZID:${TZ}`,
  'BEGIN:DAYLIGHT', 'TZOFFSETFROM:+0100', 'TZOFFSETTO:+0200', 'TZNAME:CEST', 'DTSTART:19700329T020000', 'RRULE:FREQ=YEARLY;BYMONTH=3;BYDAY=-1SU', 'END:DAYLIGHT',
  'BEGIN:STANDARD', 'TZOFFSETFROM:+0200', 'TZOFFSETTO:+0100', 'TZNAME:CET', 'DTSTART:19701025T030000', 'RRULE:FREQ=YEARLY;BYMONTH=10;BYDAY=-1SU', 'END:STANDARD',
  'END:VTIMEZONE',
];

// ── Feed ─────────────────────────────────────────────────────────
Deno.serve(async (req: Request) => {
  const notFound = () => new Response('Not found', { status: 404, headers: { 'Content-Type': 'text/plain; charset=utf-8', 'Cache-Control': 'no-store' } });
  try {
    const token = new URL(req.url).searchParams.get('token') ?? '';
    if (!/^[A-Za-z0-9_-]{32,128}$/.test(token)) return notFound();
    const feeds = await rest(`podcast_calendar_feeds?select=id,options&revoked_at=is.null&token=eq.${encodeURIComponent(token)}`);
    if (!feeds.length) return notFound();
    const feed = feeds[0];
    const o = { recordings: true, releases: true, deadlines: true, posts: false, events: true, assignee: '', ...(feed.options || {}) };
    fetch(`${SUPABASE_URL}/rest/v1/podcast_calendar_feeds?id=eq.${feed.id}`, {
      method: 'PATCH', headers: { ...H, 'Content-Type': 'application/json' }, body: JSON.stringify({ last_accessed_at: new Date().toISOString() }),
    }).catch(() => {});

    const now = new Date();
    const from = Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate() - 90);
    const to = Date.UTC(now.getUTCFullYear() + 1, now.getUTCMonth(), now.getUTCDate());
    const inRange = (l: Local | null) => !!l && toTime(l) >= from && toTime(l) <= to;
    const who = (a: string | null) => a === 'nils' ? 'Nils' : a === 'leo' ? 'Leo' : '';
    const wantAssignee = (a: string | null) => !o.assignee || a === o.assignee;
    const events: Ev[] = [];

    const episodes = (o.recordings || o.releases || o.deadlines || o.posts)
      ? await rest('podcast_episodes?select=id,title,num,date,recording_date,tasks,updated_at,guest') : [];
    const epById = new Map(episodes.map((e: any) => [e.id, e]));
    const epLabel = (e: any) => `${e.num ? '#' + e.num + ' ' : ''}${e.title}`;

    for (const e of episodes) {
      const link = `${APP_URL}#folge/${encodeURIComponent(e.id)}`;
      if (o.releases) {
        const d = parseDe(e.date);
        if (d && inRange(d)) events.push({ uid: `release-${e.id}`, summary: `🚀 Release: ${epLabel(e)}`, start: { ...d, hh: 5, mm: 30 }, minutes: 30,
          description: `Veröffentlichung der Folge „${e.title}“.\n${link}`, url: link, categories: 'Release', updatedAt: e.updated_at });
      }
      if (o.recordings && e.recording_date) {
        const d = parseDe(e.recording_date);
        if (d && inRange(d)) events.push({ uid: `recording-${e.id}`, summary: `🎙️ Aufnahme: ${e.title}`, start: d, minutes: 90, allDay: d.hh === undefined, busy: true,
          description: `${e.guest ? 'Gast: ' + e.guest + '\n' : ''}${link}`, url: link, categories: 'Aufnahme', updatedAt: e.updated_at });
      }
      if (o.deadlines) {
        for (const [stepId, v] of Object.entries<any>(e.tasks || {})) {
          if (!v || typeof v !== 'object' || v.done || !v.due) continue;
          const assignee = v.assignee === 'N' ? 'nils' : v.assignee === 'L' ? 'leo' : null;
          if (!wantAssignee(assignee)) continue;
          const d = parseIso(v.due);
          if (d && inRange(d)) events.push({ uid: `step-${e.id}-${stepId}`, summary: `⏰ ${STEP_LABELS[stepId] ?? stepId} – ${e.title}`, start: d, allDay: true,
            description: `Deadline Produktionsschritt${who(assignee) ? ' · zuständig: ' + who(assignee) : ''}\n${link}`, url: link, categories: 'Deadline', updatedAt: e.updated_at });
        }
      }
    }

    if (o.deadlines) {
      const todos = await rest('podcast_todos?select=id,text,description,assignee,due_date,priority,updated_at&done=eq.false&parent_id=is.null&due_date=not.is.null&priority=eq.high');
      for (const t of todos) {
        if (!wantAssignee(t.assignee)) continue;
        const d = parseIso(t.due_date);
        if (d && inRange(d)) events.push({ uid: `todo-${t.id}`, summary: `⏰ ${t.text}`, start: d, allDay: true,
          description: `Wichtige Aufgabe (Priorität hoch)${who(t.assignee) ? ' · zuständig: ' + who(t.assignee) : ''}${t.description ? '\n\n' + t.description : ''}\n${APP_URL}#todos`,
          url: `${APP_URL}#todos`, categories: 'Deadline', updatedAt: t.updated_at });
      }
    }

    if (o.posts) {
      const posts = await rest('podcast_posts?select=id,episode_id,format,title,date,time,assignee,status,description,updated_at');
      for (const p of posts) {
        if (!wantAssignee(p.assignee)) continue;
        const d = parseIso(p.date, p.time);
        if (!d || !inRange(d)) continue;
        const ep: any = p.episode_id ? epById.get(p.episode_id) : null;
        // Template titles ("Reel 3") only repeat the format, so show the episode instead.
        const defaultTitle = /^(Reel|Karussell|LinkedIn-Beitrag|YT-Clip) \d+$/.test(p.title || '');
        events.push({ uid: `post-${p.id}`, summary: `${p.status === 'published' ? '✓ ' : ''}${FORMAT_LABELS[p.format] ?? 'Post'}: ${(!defaultTitle && p.title) || (ep ? ep.title : '')}`,
          start: d, minutes: 15, allDay: d.hh === undefined,
          description: [ep ? `Folge: ${ep.title}` : '', who(p.assignee) ? `Zuständig: ${who(p.assignee)}` : '', p.description || '', `${APP_URL}#calendar`].filter(Boolean).join('\n'),
          url: `${APP_URL}#calendar`, categories: 'Social Media', updatedAt: p.updated_at });
      }
    }

    if (o.events) {
      const manual = await rest('podcast_events?select=*');
      for (const ev of manual) {
        const d = parseIso(ev.date, ev.all_day ? null : ev.start_time);
        if (!d || !inRange(d)) continue;
        let minutes = 60;
        const end = parseIso(ev.date, ev.end_time);
        if (!ev.all_day && end && end.hh !== undefined && d.hh !== undefined) {
          minutes = (end.hh * 60 + (end.mm ?? 0)) - (d.hh * 60 + (d.mm ?? 0));
          if (minutes <= 0) minutes += 24 * 60;
        }
        events.push({ uid: `event-${ev.id}`, summary: ev.title, start: d, minutes, allDay: ev.all_day || d.hh === undefined, busy: true,
          description: ev.notes || '', location: ev.location || '', categories: 'Termin', updatedAt: ev.updated_at });
      }
    }

    const lines = [
      'BEGIN:VCALENDAR', 'VERSION:2.0', 'PRODID:-//Glans & Gloria//Podcast Manager//DE', 'CALSCALE:GREGORIAN', 'METHOD:PUBLISH',
      'X-WR-CALNAME:Glans & Gloria', `X-WR-TIMEZONE:${TZ}`, 'REFRESH-INTERVAL;VALUE=DURATION:PT1H', 'X-PUBLISHED-TTL:PT1H',
      ...VTIMEZONE,
      ...events.flatMap(e => vevent(e, now)),
      'END:VCALENDAR',
    ];
    return new Response(lines.map(fold).join('\r\n') + '\r\n', {
      headers: {
        'Content-Type': 'text/calendar; charset=utf-8',
        'Content-Disposition': 'inline; filename="glans-gloria.ics"',
        'Cache-Control': 'no-cache, max-age=0',
      },
    });
  } catch (e) {
    console.error(e);
    return new Response('Kalender vorübergehend nicht verfügbar', { status: 503, headers: { 'Content-Type': 'text/plain; charset=utf-8', 'Retry-After': '300' } });
  }
});
