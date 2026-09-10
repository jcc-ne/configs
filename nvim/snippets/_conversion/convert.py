#!/usr/bin/env python3
"""Convert Janine's custom UltiSnips snippets to LSP-style JSON for mini.snippets."""
import json, os, re, sys

parsed = json.load(open(sys.argv[1]))
OUT = os.path.expanduser(sys.argv[2])
os.makedirs(OUT, exist_ok=True)

# Snippets we deliberately do not carry over.
DROP = {
    # heavy UltiSnips-python versions; friendly-snippets has equivalents
    ('python', 'class'), ('python', 'deff'),
}

# Hand-written replacements for the few bodies that used interpolation.
OVERRIDE = {
    ('all', 'date'):  '$CURRENT_YEAR-$CURRENT_MONTH-$CURRENT_DATE',
    ('all', 'diso'):  '$CURRENT_YEAR-$CURRENT_MONTH-$CURRENT_DATE '
                      '$CURRENT_HOUR:$CURRENT_MINUTE:$CURRENT_SECOND',
    # get_quoting_style() resolved to " (matches the ruff quote-style=double config)
    ('python', 'ifmain0'): 'if __name__ == "__main__":\n    ${1:${TM_SELECTED_TEXT:main()}}',
}

def convert_body(body, lang):
    # UltiSnips ${VISUAL[:default]} -> LSP $TM_SELECTED_TEXT
    body = re.sub(r'\$\{VISUAL:([^}]*)\}', r'${TM_SELECTED_TEXT:\1}', body)
    body = body.replace('${VISUAL}', '$TM_SELECTED_TEXT')
    body = body.replace('$VISUAL', '$TM_SELECTED_TEXT')
    # leading tabs -> 4 spaces (config is expandtab / shiftwidth=4)
    lines = []
    for line in body.split('\n'):
        m = re.match(r'^(\t+)', line)
        if m:
            line = '    ' * len(m.group(1)) + line[len(m.group(1)):]
        lines.append(line)
    return '\n'.join(lines)

def unconvertible(s):
    reasons = []
    if 'r' in s['opts']:
        reasons.append('regex trigger')
    if '`!p' in s['body'] or '`!v' in s['body']:
        reasons.append('python/vim interpolation')
    return reasons

skipped = []
for lang, rows in parsed.items():
    out = {}
    for s in rows:
        key = (lang, s['trigger'])
        # Keep her own snippets and any she edited away from upstream.
        # Untouched copies of honza's library are dropped (friendly-snippets).
        if s['cls'] == 'honza-identical' and key not in OVERRIDE:
            continue
        if key in DROP:
            skipped.append((lang, s['trigger'], 'superseded by friendly-snippets'))
            continue
        if key in OVERRIDE:
            body = OVERRIDE[key]
        else:
            reasons = unconvertible(s)
            if reasons:
                skipped.append((lang, s['trigger'], ', '.join(reasons)))
                continue
            body = convert_body(s['body'], lang)
        name = s['desc'] or s['trigger']
        # de-dup names within a file
        base, n = name, 2
        while name in out:
            name, n = f'{base} ({n})', n + 1
        out[name] = {
            'prefix': s['trigger'],
            'body': body.split('\n'),
        }
        if s['desc']:
            out[name]['description'] = s['desc']
    if out:
        fname = 'global.json' if lang == 'all' else f'{lang}.json'
        with open(os.path.join(OUT, fname), 'w') as f:
            json.dump(out, f, indent=2, ensure_ascii=False, sort_keys=True)
            f.write('\n')
        print(f'wrote {fname}: {len(out)} snippets')

print()
if skipped:
    print('NOT converted:')
    for lang, trig, why in skipped:
        print(f'  [{lang}] {trig}  -- {why}')
