#!/usr/bin/env python3
"""Parse UltiSnips .snippets files and classify against honza/vim-snippets."""
import re, os, sys, json, hashlib

SRC = os.path.expanduser('~/Repo/configs/my_patch/myBundle/UltiSnips_local')
HONZA = os.path.expanduser('~/.local/share/nvim/lazy/vim-snippets/UltiSnips')

snip_re = re.compile(r'^snippet\s+(\S+)(?:\s+"([^"]*)")?\s*(\S*)\s*$')

def parse(path):
    out = {}
    cur = None
    body = []
    for line in open(path, encoding='utf-8', errors='replace'):
        raw = line.rstrip('\n')
        if cur is None:
            m = snip_re.match(raw)
            if m:
                cur = {'trigger': m.group(1), 'desc': m.group(2) or '', 'opts': m.group(3) or ''}
                body = []
            continue
        if raw.strip() == 'endsnippet':
            cur['body'] = '\n'.join(body)
            out.setdefault(cur['trigger'], []).append(cur)
            cur = None
        else:
            body.append(raw)
    return out

def norm(b):
    return hashlib.md5('\n'.join(l.rstrip() for l in b.strip().split('\n')).encode()).hexdigest()

def has_py(s):
    return ('`!p' in s['body'] or '`!v' in s['body'] or '`!p' in s['desc'])

report = {}
for fn in sorted(os.listdir(SRC)):
    if not fn.endswith('.snippets'):
        continue
    lang = fn[:-len('.snippets')]
    mine = parse(os.path.join(SRC, fn))
    hpath = os.path.join(HONZA, fn)
    theirs = parse(hpath) if os.path.exists(hpath) else {}
    # honza 'all' also applies
    rows = []
    for trig, lst in mine.items():
        for s in lst:
            up = theirs.get(trig, [])
            if any(norm(t['body']) == norm(s['body']) for t in up):
                cls = 'honza-identical'
            elif up:
                cls = 'honza-modified'
            else:
                cls = 'CUSTOM'
            rows.append((trig, cls, 'PY' if has_py(s) else 'plain', s))
    report[lang] = rows

for lang, rows in report.items():
    c = sum(1 for r in rows if r[1] == 'CUSTOM')
    m = sum(1 for r in rows if r[1] == 'honza-modified')
    i = sum(1 for r in rows if r[1] == 'honza-identical')
    cpy = sum(1 for r in rows if r[1] == 'CUSTOM' and r[2] == 'PY')
    print(f'{lang:12s} total={len(rows):4d}  CUSTOM={c:3d} (of which python={cpy:2d})  honza-modified={m:3d}  honza-identical={i:3d}')

print()
print('=== CUSTOM snippets that use python interpolation (cannot auto-convert) ===')
for lang, rows in report.items():
    for trig, cls, kind, s in rows:
        if cls == 'CUSTOM' and kind == 'PY':
            print(f'  [{lang}] {trig}  "{s["desc"]}"')

json.dump({l: [{'trigger': t, 'cls': c, 'kind': k, **s} for t, c, k, s in rows]
           for l, rows in report.items()},
          open(sys.argv[1], 'w'), indent=1)
