# /xia — Borrow and Adapt from GitHub Projects

**Xỉa** (Vietnamese): to borrow/take something from others and use it in your own product.

This command implements a **comparative borrowing** strategy: understand your own codebase A, analyze foreign repo B, identify what A is missing that B solves well, and synthesize a more complete AB. Repeat with C, D... to build ABCD.

## Usage

```
/xia <github-repo> [focus]
```

- `<github-repo>`: GitHub URL or `user/repo` shorthand
- `[focus]`: Optional — specific aspect to focus on (e.g., "hook system", "agent memory", "prompt engineering")

## Workflow

### Phase 0 — Know A (your current codebase)

Before looking at B, understand what A already has and where its gaps are.

```
mcporter call repomix.pack_codebase(directory: ".", compress: true)
```

Also read `~/.claude/XIALOGUE.md` to understand the **evolved state** of A — what has already been borrowed from prior Xỉa sessions. A is not the original codebase; it is A + all prior Xỉa results.

Then run a brief sequential-thinking analysis of A:
```
npx mcporter call "sequential-thinking.start_session(problem: \"What does A currently do well, and where are its gaps?\", success_criteria: \"Clear gap list to compare against B\", session_type: \"coding\")"
```

Add one thought cataloguing A's capabilities and known weaknesses.

### Phase 1 — Ingest B

Pack the remote repository:

```
mcporter call repomix.pack_remote_repository(remote: "$ARGUMENTS", compress: true)
```

If a focus keyword was provided, grep immediately:
```
mcporter call repomix.grep_repomix_output(outputId: "<id>", pattern: "<focus>")
```

### Phase 2 — Compare A vs B

Create a **gap-analysis branch** in the active session:

```
npx mcporter call "sequential-thinking.create_branch(name: \"gap-analysis\", from_thought: \"<last-thought-id>\", purpose: \"Compare A capabilities against B to find what is worth borrowing\")"
```

For each analysis dimension, add a thought:

1. **What does B solve that A doesn't?** — B's unique capabilities relative to A's gaps
2. **What does A do better than B?** — don't borrow what A already handles well
3. **Integration friction** — what from B can merge cleanly vs. what would conflict with A's existing patterns?

Score each candidate by: **value** (how much does A improve?) × **friction** (how hard to integrate?).

### Phase 3 — Targeted Dialogue

Present the comparative findings, not just a list of B's features:

> "A currently lacks: [X, Y, Z].
> B addresses: X well (low friction), Y partially (medium friction), Z (high friction — conflicts with A's [pattern]).
>
> Recommended Xỉa targets: X first, then Y.
> Skip Z for now — here's why: [reason].
>
> Confirm, or tell me which to focus on."

Wait for user confirmation before proceeding.

### Phase 4 — Adapt

Transform the chosen insight into A's context:
- Rename to match A's conventions
- Strip what doesn't apply
- Identify where in A this plugs in (the **seam detection** problem)

**If GitNexus is indexed** (`.gitnexus/` exists in the project), use it for seam detection:
```
gitnexus_query --symbol "<relevant-local-symbol>"
gitnexus_context --file "<proposed-integration-file>"
gitnexus_impact --symbol "<symbol-to-be-changed>" --depth 2
```

Skip if GitNexus is not set up — describe integration points manually using the packed A output from Phase 0.

### Phase 5 — Save

Write the extracted pattern to `~/.claude/skills/learned/xia-[repo-slug]-[pattern].md`:

```markdown
---
name: xia-[repo-slug]-[pattern]
source: https://github.com/[repo]
extracted: [date]
type: learned
---

# [Pattern Name] — Xỉa from [repo]

**Source**: [repo URL]
**Extracted**: [date]
**Focus**: [what was borrowed]
**Gap filled**: [what A was missing that this addresses]

## What this is

[2-3 sentence description of the pattern]

## Why it's valuable

[Why this fills A's gap better than alternatives]

## The pattern

[Core code or pseudocode]

## How to apply here

[Concrete application in this project's context, referencing A's specific files/symbols]

## Original context

[How source repo B used it]
```

### Phase 6 — Log

Append to `~/.claude/XIALOGUE.md`:

```
| [date] | [repo] | [pattern] | [gap filled] | [saved-to] |
```

The XIALOGUE.md is A's **evolution log** — each row represents one step in the A → AB → ABC chain. When Phase 0 runs in a future session, it reads this log to understand the current evolved state of A.

## Notes

- Do NOT copy code verbatim — the goal is understanding and adaptation
- One Xỉa session = one focused pattern (not the whole repo)
- Phase 0 is skipped if the working directory has no meaningful codebase (e.g., you're in a scratch folder) — in that case, B-only analysis runs
- If the repo is very large, use `compress: true` and grep before reading full output
- Chain multiple `/xia` calls to build: A → AB → ABC → ABCD
