---
description: Implement an approved plan phase-by-phase with checkbox tracking and human gates
---

# Implement Plan

You are tasked with implementing an approved plan. Execute phase-by-phase, track progress in the plan file itself, and pause for human verification after each phase's automated checks pass.

## Getting Started

If given a plan path:
- Read the plan completely, note existing checkmarks (`- [x]`)
- Read all files mentioned in the plan FULLY
- Create a TodoWrite list mirroring the plan phases
- Start from the first unchecked item

If no plan path provided, ask for one.

## Implementation Philosophy

Plans are carefully designed, but reality is messy. Your job:
- Follow the plan's **intent**, not just its words
- Implement each phase fully before moving to the next
- Update checkboxes in the plan file as sections complete
- Keep the end goal in mind; maintain forward momentum

**When reality diverges from the plan, STOP and report:**
```
Issue in Phase [N]:
Expected: [what the plan says]
Found: [actual situation]
Why this matters: [explanation]

How should I proceed?
```

## Verification Approach

After implementing each phase:
1. Run all automated success criteria from the plan
2. Fix any failures before proceeding
3. Check off completed items in the plan file with Edit
4. Pause with this message:

```
Phase [N] Complete — Ready for Manual Verification

Automated checks passed:
- [check: command]
- [check: command]

Please perform manual verification:
- [ ] [Manual step from plan]
- [ ] [Manual step from plan]

Let me know when done so I can proceed to Phase [N+1].
```

Do NOT check off manual items until the user confirms them.

If instructed to run multiple phases consecutively, skip the pause between phases — only pause at the final phase.

## If Stuck

- Re-read the relevant code before asking
- Consider if the codebase has evolved since the plan was written
- Present the mismatch clearly and ask for guidance
- Use sub-agents only for targeted exploration of unfamiliar code

## Resuming

If the plan has existing checkmarks:
- Trust that completed work is done
- Start from the first unchecked item
- Verify previous work only if something seems off
