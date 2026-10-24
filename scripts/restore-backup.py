#!/usr/bin/env python3
"""Restore a Podcast-Planer JSON backup into Supabase.

Never deletes rows. Rows are upserted by primary key, so existing rows with the
same id are overwritten with the backup version and newer rows are kept.

Usage:
  python3 scripts/restore-backup.py backup.json                 # dry run (read-only)
  SUPABASE_SERVICE_KEY=... python3 scripts/restore-backup.py backup.json --apply
  ... --tables podcast_episodes,podcast_ideas                   # restrict tables

The service key (Supabase Dashboard -> Project Settings -> API -> service_role)
is only read from the environment, never stored. Dry run needs no key if the
anon key can still read the tables; otherwise pass the service key as well.
"""
import json
import os
import subprocess
import sys

URL = 'https://wkqaktxdrtohwzrtpjrh.supabase.co'
ANON = ('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndrcWFrdHhkcnRvaHd6cnRwanJoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODM4NzY4MzEsImV4cCI6MjA5OTQ1MjgzMX0.'
        'L0kawLGbIJIZaeEcuRtueV0fZDZM-xmFLaZrVn2LtHo')
PKEYS = {'podcast_prompts': 'task_id', 'app_users': 'email'}


def request(method, path, key, body=None, prefer=None):
    cmd = ['curl', '-s', '-w', '\n%{http_code}', '-X', method, URL + '/rest/v1/' + path,
           '-H', 'apikey: ' + key, '-H', 'Authorization: Bearer ' + key,
           '-H', 'Content-Type: application/json']
    if prefer:
        cmd += ['-H', 'Prefer: ' + prefer]
    if body is not None:
        cmd += ['--data-binary', '@-']
    out = subprocess.run(cmd, input=json.dumps(body) if body is not None else None,
                         capture_output=True, text=True).stdout
    text, _, code = out.rpartition('\n')
    if not code.startswith('2'):
        raise SystemExit(f'{method} {path} failed ({code}): {text}')
    return json.loads(text) if text.strip() else None


def main():
    args = sys.argv[1:]
    if not args:
        raise SystemExit(__doc__)
    apply = '--apply' in args
    only = None
    if '--tables' in args:
        only = set(args[args.index('--tables') + 1].split(','))
    backup = json.load(open(args[0], encoding='utf-8'))
    data = backup.get('data', backup)
    key = os.environ.get('SUPABASE_SERVICE_KEY') or (None if apply else ANON)
    if not key:
        raise SystemExit('Für --apply muss SUPABASE_SERVICE_KEY gesetzt sein.')

    for table, rows in sorted(data.items()):
        if only and table not in only:
            continue
        pk = PKEYS.get(table, 'id')
        live = request('GET', f'{table}?select=*', key)
        live_by_id = {r[pk]: r for r in live}
        new = [r for r in rows if r[pk] not in live_by_id]
        changed = [r for r in rows if r[pk] in live_by_id and live_by_id[r[pk]] != r]
        only_live = len(set(live_by_id) - {r[pk] for r in rows})
        print(f'{table}: backup={len(rows)} live={len(live)} -> neu={len(new)} '
              f'überschrieben={len(changed)} nur-live(bleiben)={only_live}')
        if apply and (new or changed):
            request('POST', f'{table}?on_conflict={pk}', key, new + changed,
                    prefer='resolution=merge-duplicates,return=minimal')
            print('   wiederhergestellt.')
    if not apply:
        print('\nDry run – nichts geschrieben. Mit --apply (und SUPABASE_SERVICE_KEY) ausführen.')


if __name__ == '__main__':
    main()
