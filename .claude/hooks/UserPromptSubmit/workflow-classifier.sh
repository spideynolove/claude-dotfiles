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

# Priority 1: debug
if echo "$PROMPT" | grep -qE "(bug|error|fail|not working|broken|trace|why (does|is|isn't|should|do))"; then
  echo "[workflow:debug] Root cause first, not symptoms. Trace → identify → fix. No plan needed for single bugs."
  exit 0
fi

# Priority 2: plan
if echo "$PROMPT" | grep -qE "(plan|design|architect|how should i|how do i approach|structure|scaffold)"; then
  echo "[workflow:plan] Concise plan first (≤7 bullets). No code until plan is approved. Verify steps upfront."
  exit 0
fi

# Priority 3: review
if echo "$PROMPT" | grep -qE "(review|audit|code review|pr review|look at this|check this)"; then
  echo "[workflow:review] Verify before done. Run tests/checks. Would a senior engineer approve this?"
  exit 0
fi

# Priority 4: impl
if echo "$PROMPT" | grep -qE "(implement|build|add feature|create|write a|make a)"; then
  echo "[workflow:impl] Minimal change. Touch only what's needed. Follow existing patterns. No new abstractions."
  exit 0
fi

exit 0
