# Hooks Archive

Previously stored in `.claude/hooks/`. Removed to reduce complexity — restore selectively when needed.
Hook references in `settings.json` have also been removed.

## File inventory

| Original path | Type | Purpose |
|---|---|---|
| `hooks/UserPromptSubmit/context-loader.sh` | bash | Inject `.aim/memory.jsonl` knowledge graph + handoff.md into each session (once per session via marker file) |
| `hooks/UserPromptSubmit/gate.py` | python | Block prompts after 5+ edits until `/simplify` is run |
| `hooks/UserPromptSubmit/workflow-classifier.sh` | bash | Detect workflow type (debug/plan/review/impl) from prompt text — unused placeholder |
| `hooks/UserPromptSubmit/test-classifier.sh` | bash | Test suite for workflow-classifier.sh — not a hook, a test runner |
| `hooks/PostToolUse/counter.py` | python | Count file edits per session; trigger simplify gate at threshold |
| `hooks/context-loader.sh` | bash | Legacy copy of UserPromptSubmit/context-loader.sh (symlinked) |
| `hooks/sync-skills-to-codex.py` | python | On Edit/Write to `.claude/skills/`, sync symlinks to `~/.codex/skills/` and `~/.qwen/skills/` |

## How hooks were wired (settings.json)

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/hooks/UserPromptSubmit/context-loader.sh"
          }
        ]
      }
    ]
  }
}
```

Note: `gate.py`, `counter.py`, and `sync-skills-to-codex.py` were NOT wired in settings.json — they existed as files but had no active trigger.

## File contents

### hooks/UserPromptSubmit/context-loader.sh

```bash
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

if [ -f ".claude/handoff.md" ]; then
  echo ""
  echo "[handoff] Resuming from previous session:"
  cat ".claude/handoff.md"
fi

exit 0
```

### hooks/UserPromptSubmit/gate.py

```python
#!/usr/bin/env python3
import json
import re
import sys
from pathlib import Path

THRESHOLD = 5


def main():
    try:
        data = json.load(sys.stdin)
    except json.JSONDecodeError:
        sys.exit(0)

    session_id = data.get("session_id", "")
    session_id = re.sub(r"[^a-zA-Z0-9_-]", "_", session_id) or "unknown"
    prompt = data.get("prompt", "").strip()
    count_file = Path(f"/tmp/cc-edits-{session_id}")
    done_file = Path(f"/tmp/cc-simplified-{session_id}")

    if prompt.lower() == "/simplify":
        try:
            done_file.touch()
            count_file.write_text("0")
        except OSError:
            pass
        sys.exit(0)

    try:
        count = int(count_file.read_text()) if count_file.exists() else 0
    except (ValueError, OSError):
        count = 0

    if count >= THRESHOLD and not done_file.exists():
        print(
            f"[AUTO-SIMPLIFY] {count} edits pending simplification. "
            "Type /simplify before continuing.",
            file=sys.stderr,
        )
        sys.exit(2)


if __name__ == "__main__":
    main()
```

### hooks/PostToolUse/counter.py

```python
#!/usr/bin/env python3
import json
import re
import sys
from pathlib import Path

THRESHOLD = 5


def main():
    try:
        data = json.load(sys.stdin)
    except json.JSONDecodeError:
        sys.exit(0)

    session_id = data.get("session_id", "")
    session_id = re.sub(r"[^a-zA-Z0-9_-]", "_", session_id) or "unknown"
    count_file = Path(f"/tmp/cc-edits-{session_id}")
    done_file = Path(f"/tmp/cc-simplified-{session_id}")

    if done_file.exists():
        try:
            done_file.unlink()
            count_file.write_text("0")
        except OSError:
            pass
        sys.exit(0)

    try:
        count = int(count_file.read_text()) if count_file.exists() else 0
    except (ValueError, OSError):
        count = 0
    count += 1
    try:
        count_file.write_text(str(count))
    except OSError:
        sys.exit(0)

    if count >= THRESHOLD:
        print(
            f"[AUTO-SIMPLIFY] {count} file edits this session. "
            "Invoke the simplify skill now before continuing. "
            "Use: Skill(skill='simplify')",
            file=sys.stderr,
        )
        sys.exit(2)


if __name__ == "__main__":
    main()
```

### hooks/UserPromptSubmit/workflow-classifier.sh

```bash
#!/bin/bash
set +e

PROMPT=$(python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    print(d.get('prompt', '').lower())
except:
    pass
" 2>/dev/null)

[ -z "$PROMPT" ] && exit 0

if echo "$PROMPT" | grep -qE "(bug|error|fail|not working|broken|trace|why (does|is|isn't|should|do))"; then
  echo "[workflow:debug] Root cause first, not symptoms. Trace → identify → fix. No plan needed for single bugs."
  exit 0
fi

if echo "$PROMPT" | grep -qE "(plan|design|architect|how should i|how do i approach|structure|scaffold)"; then
  echo "[workflow:plan] Concise plan first (≤7 bullets). No code until plan is approved. Verify steps upfront."
  exit 0
fi

if echo "$PROMPT" | grep -qE "(review|audit|code review|pr review|look at this|check this)"; then
  echo "[workflow:review] Verify before done. Run tests/checks. Would a senior engineer approve this?"
  exit 0
fi

if echo "$PROMPT" | grep -qE "(implement|build|add feature|create|write a|make a)"; then
  echo "[workflow:impl] Minimal change. Touch only what's needed. Follow existing patterns. No new abstractions."
  exit 0
fi

exit 0
```

### hooks/sync-skills-to-codex.py

Syncs `~/.claude/skills/` → `~/.codex/skills/` and `~/.qwen/skills/` via symlinks.
Reads `targets:` frontmatter field to decide which tools a skill should sync to.
Manages a `.skillshare-manifest.json` in each target directory.
Can run as a hook (`--hook` flag reads PostToolUse stdin) or standalone (`--dry-run`).
