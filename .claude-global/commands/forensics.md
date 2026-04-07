---
description: Post-mortem investigation for stuck or failed workflows — read-only diagnostic
argument-hint: "[problem description]"
---

# /forensics — Workflow Post-Mortem

Post-mortem investigation for stuck or failed workflows. **Read-only — never modifies project files.**

## Step 1: Get Problem Description

If `$ARGUMENTS` is empty, ask: "What went wrong? e.g., 'got stuck on phase 3', 'plan execute failed silently', 'costs seem high'."

## Step 2: Gather Evidence

```bash
# Commit timeline and frequency
git log --oneline -30
git log --format="%H %ai %s" -30

# Most-edited files (stuck-loop signal)
git log --name-only --format="" -20 | sort | uniq -c | sort -rn | head -20

# Uncommitted work (crash/interruption signal)
git status --short && git diff --stat

# Orphaned worktrees
git worktree list
```

Also read if they exist:
- `.planning/STATE.md` — current position, blockers, last session
- `.planning/ROADMAP.md` — phase progress
- `.planning/phases/*/` — check for missing SUMMARY.md or VERIFICATION.md per phase

## Step 3: Detect Anomalies

| Anomaly | Signal |
|---|---|
| Stuck loop | Same file in 3+ consecutive commits, similar messages |
| Missing artifact | Phase appears complete but no SUMMARY.md |
| Abandoned work | Large time gap + STATE.md shows "In progress" |
| Orphaned worktree | `git worktree list` path no longer active |

## Step 4: Write Report

Save to `.planning/forensics/report-TIMESTAMP.md`:

```markdown
# Forensics Report: [Problem]
**Date:** [timestamp]
**Confidence:** HIGH / MEDIUM / LOW

## Summary
[1-2 sentence diagnosis]

## Anomalies Found
- [TYPE] [description]

## Root Cause
[Most likely cause]

## Recommended Actions
1. [Action]
2. [Action]
```

Present report inline. Offer deeper investigation if needed.
