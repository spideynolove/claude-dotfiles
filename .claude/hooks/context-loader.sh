#!/bin/bash
SESSION_ID=$(python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('session_id',''))" 2>/dev/null)
[ -z "$SESSION_ID" ] && exit 0

MARKER="/tmp/claude-kg-$SESSION_ID"
[ -f "$MARKER" ] && exit 0

AIM_FILES=(.aim/memory*.jsonl)
[ ! -e "${AIM_FILES[0]}" ] && exit 0

touch "$MARKER"

python3 -c "
import json, sys, glob
entities, relations = [], []
for path in sorted(glob.glob('.aim/memory*.jsonl')):
    with open(path) as f:
    for line in f:
        line = line.strip()
        if not line: continue
        try:
            obj = json.loads(line)
            t = obj.get('type')
            if t == 'entity': entities.append(obj)
            elif t == 'relation': relations.append(obj)
        except: pass

if not entities:
    sys.exit(0)

print('[knowledge-graph] Project context loaded:')
for e in entities[:15]:
    obs = '; '.join(e.get('observations', [])[:2])
    print(f\"  {e['name']} ({e.get('entityType','?')}): {obs}\")
if len(entities) > 15:
    print(f'  ... {len(entities)-15} more entities')
print(f'  {len(relations)} relations indexed')
" 2>/dev/null

exit 0
