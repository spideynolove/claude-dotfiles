---
description: Validate implementation against plan — run automated checks, surface manual items, generate report
---

# Validate Plan

You are tasked with validating that an implementation plan was correctly executed. Run all automated success criteria, identify deviations, and list what still needs manual verification.

## Setup

When invoked:
1. Locate the plan (use path if provided; otherwise check recent commits or ask)
2. Gather implementation evidence:
   ```bash
   git log --oneline -n 20
   git diff HEAD~N..HEAD  # cover implementation commits
   ```
3. Read the plan completely

## Validation Process

### Step 1: Discover What Was Done

Spawn parallel research agents to verify:
- Which files were changed vs what the plan specified
- Whether tests were added/updated as specified
- Whether automated criteria commands actually pass

### Step 2: Systematic Check Per Phase

For each phase:
1. Check completion status — look for `- [x]` checkmarks
2. Run every command from "Automated Verification"
3. Document pass/fail
4. Think about edge cases: error handling, regressions, missing validations

### Step 3: Generate Validation Report

```markdown
## Validation Report: [Plan Name]

### Implementation Status
✓ Phase 1: [Name] — Fully implemented
✓ Phase 2: [Name] — Fully implemented
⚠️ Phase 3: [Name] — Partially implemented

### Automated Verification Results
✓ [command] — passed
✗ [command] — failed: [reason]

### Code Review Findings

#### Matches Plan:
- [Finding: file:line]

#### Deviations from Plan:
- [Deviation: file:line] ([improvement or concern])

#### Potential Issues:
- [Risk or missing piece]

### Manual Testing Required:
- [ ] [Step the human must verify]
- [ ] [Another step]

### Recommendations:
- [Action before merge]
```

## Guidelines

- Run ALL automated checks — don't skip
- Be honest about shortcuts or incomplete items from this session
- Think critically: does the implementation actually solve the problem?
- Consider maintainability, not just correctness

## Recommended Workflow

```
/create_plan → /implement_plan → /validate_plan → commit → PR
```
