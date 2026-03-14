#!/bin/bash
SESSION_ID=$(python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('session_id',''))" 2>/dev/null)
[ -z "$SESSION_ID" ] && exit 0

MARKER="/tmp/claude-kg-$SESSION_ID"
[ -f "$MARKER" ] && exit 0

touch "$MARKER"

AIM_FILES=(.aim/memory*.jsonl)
if [ -e "${AIM_FILES[0]}" ]; then
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
fi

if [ -f .aim/roles.json ]; then
  echo "[roles] $(python3 -c "import json; r=json.load(open('.aim/roles.json')); print(f\"{r['project_type']}: {', '.join(x['id'] for x in r['roles'])}\")" 2>/dev/null)"
fi

if [ -f ".claude/handoff.md" ]; then
  echo ""
  echo "[handoff] Resuming from previous session:"
  cat ".claude/handoff.md"
fi

exit 0
