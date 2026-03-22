# /xia — Borrow and Adapt from GitHub Projects

**Xỉa** (Vietnamese): to borrow/take something from others and use it in your own product.

This command implements the core learning strategy of this project: find a GitHub repo with a pattern worth learning, analyze it deeply, extract the valuable insight, and adapt it into a reusable skill.

## Usage

```
/xia <github-repo> [focus]
```

- `<github-repo>`: GitHub URL or `user/repo` shorthand
- `[focus]`: Optional — specific aspect to focus on (e.g., "hook system", "agent orchestration", "prompt engineering")

## Workflow

### Phase 1 — Ingest

Pack the remote repository using repomix:

```
mcporter call repomix.pack_remote_repository(remote: "$ARGUMENTS", compress: true)
```

If the user provided a focus keyword, also grep for it immediately:
```
mcporter call repomix.grep_repomix_output(outputId: "<id>", pattern: "<focus>")
```

### Phase 2 — Understand

Run a sequential-thinking analysis with 3 branches:

1. **Architecture branch**: How is the project structured? What are the key modules and how do they connect?
2. **Patterns branch**: What non-obvious patterns does this repo use? Hooks, conventions, abstractions?
3. **Techniques branch**: What specific techniques are worth borrowing? What Claude Code / AI patterns are demonstrated?

Use `start_session` with `session_type: "coding"` and add one thought per branch using `create_branch`.

### Phase 3 — Dialogue

After analysis, ask the user:

> "I've analyzed `[repo]`. Here are the 3 most borrowable insights:
> 1. [insight]
> 2. [insight]
> 3. [insight]
>
> Which would you like to Xỉa? Or describe what you want to extract."

### Phase 4 — Adapt

Transform the chosen insight into the user's project context:
- Rename to match local conventions
- Strip what doesn't apply
- Identify where in the current project this could plug in (the **seam detection** problem)

**If GitNexus is indexed for this project** (`.gitnexus/` exists), use it for seam detection:
```
gitnexus_query --symbol "<relevant-local-symbol>"
gitnexus_context --file "<proposed-integration-file>"
gitnexus_impact --symbol "<symbol-to-be-changed>" --depth 2
```
This finds the exact call sites and integration points where the borrowed pattern attaches. Skip if GitNexus is not set up — describe integration points manually instead.

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

## What this is

[2-3 sentence description of the pattern]

## Why it's valuable

[Why this is worth borrowing]

## The pattern

[Core code or pseudocode]

## How to apply here

[Concrete application in this project's context]

## Original context

[How the source repo used it]
```

### Phase 6 — Log

Append to `~/.claude/XIALOGUE.md` (provenance log):

```
| [date] | [repo] | [pattern] | [saved-to] |
```

If `XIALOGUE.md` doesn't exist, create it with a header table first.

## Notes

- Do NOT copy code verbatim — the goal is understanding and adaptation
- One Xỉa session = one focused pattern (not the whole repo)
- If the repo is very large, use `compress: true` and grep before reading full output
- Chain multiple `/xia` calls for multiple patterns from the same repo
