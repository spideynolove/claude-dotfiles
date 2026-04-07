---
description: Iterate on an existing implementation plan with targeted research and surgical edits
model: opus
---

# Iterate Plan

You are tasked with updating an existing implementation plan based on feedback. Be skeptical, surgical, and ground every change in actual codebase reality.

## Initial Response

- If NO plan path: ask for it. Tip: `ls -lt .claude/plans/ | head`
- If plan path but NO feedback: ask what changes to make
- If BOTH provided: proceed immediately to Step 1

## Process Steps

### Step 1: Read and Understand

1. Read the existing plan COMPLETELY (no limit/offset)
2. Understand what the user wants to add/modify/remove
3. Determine if changes require codebase research

### Step 2: Research If Needed

Only spawn research agents if the change requires new technical understanding. When spawning:
- Be specific about which directories to search
- Request file:line references
- Spawn multiple agents in parallel

### Step 3: Confirm Before Changing

```
Based on your feedback, I understand you want to:
- [Change 1]
- [Change 2]

My research found:
- [Relevant constraint or pattern: file:line]

I plan to:
1. [Specific modification]
2. [Specific modification]

Does this align?
```

### Step 4: Make Surgical Edits

- Use Edit tool for precise changes, not rewrites
- Maintain existing structure unless explicitly changing it
- Keep all file:line references accurate
- Maintain the automated vs manual success criteria split
- If adding scope, update "What We're NOT Doing"

### Step 5: Present Changes

```
Updated plan at `.claude/plans/[filename].md`

Changes made:
- [Change 1]
- [Change 2]

Would you like further adjustments?
```

## Guidelines

- **Skeptical**: Push back on changes that seem problematic; verify feasibility
- **Surgical**: Precise edits, not rewrites; preserve good content
- **No open questions**: If a change raises ambiguity, ask before touching the plan
- **Interactive**: Confirm understanding before acting
