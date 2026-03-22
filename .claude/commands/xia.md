# /xia — Borrow and Adapt from GitHub Projects

**Xỉa** (Vietnamese): to borrow/take something from others and use it in your own product.

This command implements a **comparative borrowing** strategy: understand your own codebase A, analyze foreign repo B, identify what A is missing that B solves well, and synthesize a more complete AB. Repeat with C, D... to build ABCD.

## Usage

```
/xia <github-repo> [focus]
```

- `<github-repo>`: GitHub URL or `user/repo` shorthand
- `[focus]`: Optional — specific aspect to focus on (e.g., "hook system", "agent memory")

## Storage convention

Xỉa state is **project-local**, stored in the repository itself:

```
<project-root>/
└── .claude/
    └── xia/
        ├── XIALOGUE.md        ← evolution log (committed to git)
        └── patterns/
            └── xia-repo-B-pattern.md
```

**Why project-local?** `~/.claude` is machine-local and not in git — it mixes all projects together and disappears when you move to another PC. `.claude/xia/` travels with the repo: clone on any machine and the full Xỉa history is immediately available.

The global `~/.claude/skills/learned/` is optionally used only for patterns generic enough to be useful across ALL projects.

## Workflow

### Phase 0 — Know A (current state of this project)

Check `.claude/xia/XIALOGUE.md` in the current working directory:

- **File missing** → first Xỉa session on this project. A = raw codebase with no prior borrows.
- **File exists** → read the "Current evolved state of A" summary at the top. This tells you what A already has from prior sessions without replaying every session.

Then pack the local codebase for gap analysis:

```
mcporter call repomix.pack_codebase(directory: ".", compress: true)
```

Run a brief sequential-thinking analysis:
```
npx mcporter call "sequential-thinking.start_session(problem: \"What does A currently do well, and where are its gaps?\", success_criteria: \"Gap list to compare against B\", session_type: \"coding\")"
```

### Phase 1 — Ingest B

Pack the remote repository:

```
mcporter call repomix.pack_remote_repository(remote: "$ARGUMENTS", compress: true)
```

If a focus keyword was provided, grep immediately:
```
Grep(pattern: "<focus>", path: "<outputFilePath>")
```

### Phase 2 — Compare A vs B

Create a **gap-analysis branch** in the active session:

```
npx mcporter call "sequential-thinking.create_branch(name: \"gap-analysis\", from_thought: \"<last-thought-id>\", purpose: \"Compare A vs B to find what is worth borrowing\")"
```

For each analysis dimension, add a thought:

1. **What does B solve that A doesn't?** — B's unique capabilities relative to A's gaps
2. **What does A do better than B?** — don't borrow what A already handles well
3. **Integration friction** — what from B can merge cleanly vs. what conflicts with A's patterns?

Score each candidate by: **value** (how much does A improve?) × **friction** (how hard to integrate?).

### Phase 3 — Targeted Dialogue

Present the comparative findings:

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
- Identify where in A this plugs in (seam detection)

**If GitNexus is indexed** (`.gitnexus/` exists), use it for seam detection:
```
gitnexus_query --symbol "<relevant-local-symbol>"
gitnexus_impact --symbol "<symbol-to-be-changed>" --depth 2
```

Skip if GitNexus is not set up — describe integration points manually using the Phase 0 packed output.

### Phase 5 — Save (project-local)

Write the extracted pattern to `.claude/xia/patterns/xia-[repo-slug]-[pattern].md`:

```markdown
---
name: xia-[repo-slug]-[pattern]
source: https://github.com/[repo]
extracted: [date]
---

# [Pattern Name] — Xỉa from [repo]

**Source**: [repo URL]
**Extracted**: [date]
**Gap filled**: [what A was missing that this addresses]

## What this is

[2-3 sentence description]

## Why it fills A's gap

[Why this addresses the specific gap identified in Phase 2]

## The pattern

[Core code or pseudocode — no comments, no docstrings]

## How to apply here

[Concrete application in this project, referencing A's specific files/symbols]

## Original context

[How source repo B used it]
```

Optionally also save to `~/.claude/skills/learned/` if the pattern is generic enough to apply to other projects.

### Phase 6 — Log (update XIALOGUE.md)

Update `.claude/xia/XIALOGUE.md` with two things:

**1. Update the "Current evolved state of A" summary at the top** — revise the prose to reflect what A can now do after this borrow. This is what Phase 0 reads on the next session (possibly from a different PC).

**2. Append a row to the borrow table:**

```
| [date] | [repo] | [pattern] | [gap filled] | .claude/xia/patterns/[file] |
```

If `.claude/xia/XIALOGUE.md` does not exist, create it using this template:

```markdown
# XIALOGUE — [Project Name]

## Current evolved state of A

[One paragraph describing what this project currently does, what patterns it uses,
and what has been borrowed so far. Written as present-tense capability description.
Update this summary after every Xỉa session.]

*First Xỉa session — no prior borrows.*

---

## Borrow history

| Date | Source | Pattern | Gap filled | Saved to |
|------|--------|---------|------------|----------|
```

## Commit after each session

After Phase 6, the `.claude/xia/` directory should be committed:

```bash
git add .claude/xia/
git commit -m "xia: borrow [pattern] from [repo]"
```

This makes the Xỉa state available on every machine that pulls the repo.
