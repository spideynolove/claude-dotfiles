---
name: handoff
description: Generate or update .claude/handoff.md to capture current work state before leaving a machine. Invoke before ending a session when work will continue on a different PC.
---

## When to invoke

- Before ending a session when work is not complete
- When switching machines mid-task
- When you want Claude to summarize where things stand

## What to write

Generate `.claude/handoff.md` with this exact structure:

```markdown
# Handoff — <date>

## Current task
<one sentence: what was actively being worked on right now>

## Next steps
- [ ] <concrete next action — specific enough to act on without reading the whole conversation>
- [ ] <second action>
- [ ] ...

## Open questions
- <something that was about to be investigated but wasn't yet>

## Decisions made
- <decision>: <why — so it is not re-litigated on the next machine>

## Files in flight
- <path>: <what state it is in — partially done, needs review, etc.>

## Blockers
- <anything that stopped or slowed progress, if any>
```

## Rules

- **Current task**: one sentence maximum. What was the active work, not the overall project goal.
- **Next steps**: must be concrete and immediately actionable. "Continue working on auth" is bad. "Add rate limit middleware to src/api/routes.ts after the auth check" is good.
- **Decisions made**: only decisions that could be re-litigated — architectural choices, rejected approaches. Not obvious things.
- **Files in flight**: only files with uncommitted or partial changes.
- **Omit empty sections** — if there are no blockers, omit the blockers section entirely.

## After writing

```bash
mkdir -p .claude
# write the file, then:
git add .claude/handoff.md
git commit -m "chore: update handoff"
git push
```

This makes the handoff available on any machine that pulls the repo.

## On the receiving machine

No action needed. `context-loader.sh` fires on session start and automatically injects `.claude/handoff.md` if it exists.

## Clearing the handoff

Once work is complete (feature merged, task done), delete the file:

```bash
rm .claude/handoff.md
git add .claude/handoff.md
git commit -m "chore: clear handoff"
git push
```
