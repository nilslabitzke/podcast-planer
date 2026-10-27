import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const URL_ = Deno.env.get('SUPABASE_URL')!;
const KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const BUCKET = 'backups';
const KEEP = 12;
const H = { apikey: KEY, Authorization: 'Bearer ' + KEY };

// All tables exposed by PostgREST, so new tables are backed up automatically.
async function listTables(): Promise<string[]> {
  const r = await fetch(`${URL_}/rest/v1/`, { headers: { ...H, Accept: 'application/openapi+json' } });
  if (!r.ok) throw new Error('openapi: ' + await r.text());
  const spec = await r.json();
  return Object.keys(spec.definitions || {}).sort();
}

// Receipts (private bucket "receipts") are mirrored into backups/receipts/<path>.
// Files are immutable (new upload = new path), so already copied files are skipped.
async function mirrorReceipts(data: Record<string, unknown>) {
  const paths = new Set<string>();
  for (const t of ['podcast_fin_bookings', 'podcast_fin_recurring']) {
    for (const row of (data[t] as { receipt_path?: string }[] | undefined) || []) if (row.receipt_path) paths.add(row.receipt_path);
  }
  let copied = 0, failed = 0;
  for (const p of paths) {
    const r = await fetch(`${URL_}/storage/v1/object/copy`, {
      method: 'POST', headers: { ...H, 'Content-Type': 'application/json' },
      body: JSON.stringify({ bucketId: 'receipts', sourceKey: p, destinationBucket: BUCKET, destinationKey: `receipts/${p}` }),
    });
    if (r.ok) copied++;
    else if (!/already exists|Duplicate|409/i.test(await r.text())) failed++;
  }
  return { total: paths.size, copied, failed };
}

Deno.serve(async () => {
  try {
    const tables = await listTables();
    if (!tables.includes('podcast_episodes')) throw new Error('table list incomplete: ' + tables.join(','));
    const data: Record<string, unknown> = {};
    for (const t of tables) {
      const r = await fetch(`${URL_}/rest/v1/${t}?select=*`, { headers: H });
      if (!r.ok) throw new Error(`${t}: ${await r.text()}`);
      data[t] = await r.json();
    }
    const name = `backup-${new Date().toISOString().slice(0, 10)}.json`;
    const up = await fetch(`${URL_}/storage/v1/object/${BUCKET}/${name}`, {
      method: 'POST',
      headers: { ...H, 'Content-Type': 'application/json', 'x-upsert': 'true' },
      body: JSON.stringify({ created_at: new Date().toISOString(), data }),
    });
    if (!up.ok) throw new Error('upload: ' + await up.text());
    const receipts = await mirrorReceipts(data);

    const ls = await fetch(`${URL_}/storage/v1/object/list/${BUCKET}`, {
      method: 'POST',
      headers: { ...H, 'Content-Type': 'application/json' },
      body: JSON.stringify({ prefix: '', limit: 200, sortBy: { column: 'name', order: 'desc' } }),
    });
    const files: { name: string }[] = ls.ok ? await ls.json() : [];
    const old = files.map(f => f.name).filter(n => n.startsWith('backup-')).sort().reverse().slice(KEEP);
    if (old.length) {
      await fetch(`${URL_}/storage/v1/object/${BUCKET}`, {
        method: 'DELETE',
        headers: { ...H, 'Content-Type': 'application/json' },
        body: JSON.stringify({ prefixes: old }),
      });
    }
    const counts = Object.fromEntries(Object.entries(data).map(([k, v]) => [k, (v as unknown[]).length]));
    return new Response(JSON.stringify({ ok: true, file: name, counts, receipts, pruned: old.length }), { headers: { 'Content-Type': 'application/json' } });
  } catch (e) {
    return new Response(JSON.stringify({ ok: false, error: String(e) }), { status: 500, headers: { 'Content-Type': 'application/json' } });
  }
});
