---
description: Create detailed implementation plans through interactive research and iteration
model: opus
---

# Create Plan

You are tasked with creating a detailed implementation plan through an interactive, iterative process. Be skeptical, thorough, and work collaboratively to produce a high-quality technical specification before any code is written.

## Initial Response

If no parameters provided:
```
I'll help you create a detailed implementation plan. Please provide:
1. The task/feature description
2. Any relevant context or constraints
3. Links to related files or prior research

Tip: You can invoke directly with a description: `/create_plan add rate limiting to the API`
```

If parameters provided, proceed immediately to Step 1.

## Process Steps

### Step 1: Context Gathering

1. Read ALL mentioned files COMPLETELY — no limit/offset, no partial reads
2. Spawn parallel research agents to find relevant code, patterns, and tests
3. Cross-reference requirements with actual codebase state
4. Only ask questions that code investigation cannot answer:
   ```
   Based on my research, I understand we need to [accurate summary].

   Discovered:
   - [Finding with file:line reference]
   - [Pattern or constraint]

   Questions code can't answer:
   - [Business logic or design preference]
   ```

### Step 2: Design Options

Present design alternatives with trade-offs before committing to an approach:
```
Design Options:
1. [Option A] — pros/cons
2. [Option B] — pros/cons

Which aligns with your vision?
```

### Step 3: Plan Structure Approval

Before writing details, get buy-in on phasing:
```
Proposed phases:
1. [Phase] — [what it accomplishes]
2. [Phase] — [what it accomplishes]

Does this phasing make sense?
```

### Step 4: Write the Plan

Save to `.claude/plans/YYYY-MM-DD-description.md` using this template:

```markdown
# [Feature] Implementation Plan

## Overview
[1-2 sentence summary]

## Current State Analysis
[What exists, what's missing, key constraints with file:line refs]

### Key Discoveries:
- [Finding: file:line]

## Desired End State
[Specification of done state and how to verify it]

## What We're NOT Doing
[Explicit scope exclusions]

## Implementation Approach
[Strategy and reasoning]

## Phase 1: [Name]

### Changes Required:
#### 1. [Component]
**File**: `path/to/file`
**Changes**: [summary]

### Success Criteria:

#### Automated Verification:
- [ ] Tests pass: `[command]`
- [ ] Type/lint checks pass: `[command]`

#### Manual Verification:
- [ ] [Human-required check]

**Implementation Note**: Pause after automated verification passes. Human confirms manual steps before Phase 2.

---

## Phase 2: [Name]
[Same structure]

---

## Testing Strategy
[Unit, integration, manual steps]

## References
- [file:line or research doc]
```

### Step 5: Review

Present the plan location and ask:
- Are phases properly scoped?
- Are success criteria specific enough?
- Missing edge cases?

Iterate until the user is satisfied. **No open questions in the final plan** — resolve everything before sign-off.

## Guidelines

- **Skeptical**: Question vague requirements; verify assumptions with code
- **Interactive**: Get buy-in at each step; don't write the full plan in one shot
- **Thorough**: Read all context fully; include file:line references; separate automated vs manual criteria
- **Practical**: Incremental and testable phases; include "What We're NOT Doing"
- **No open questions**: If unresolved, research or ask — never finalize with ambiguity
