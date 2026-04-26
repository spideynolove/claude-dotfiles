---
name: agents-refine
description: Iterative multi-model AGENTS.md refinement loop. Opus evaluates → patches → Codex evaluates → patches → Opus final polish. Supports root HLD mode and project LLD mode (references root).
trigger: /agents-refine
---

# /agents-refine

Refine AGENTS.md files through a multi-model evaluation loop: Claude (Opus) → Codex → Claude final pass. Produces HLD (root) and LLD (project-specific) rules with measurable improvement each cycle.

## Usage

```
/agents-refine                        # refine AGENTS.md in current directory (auto-detect root vs project)
/agents-refine root                   # explicitly refine root/HLD AGENTS.md
/agents-refine project [path]         # refine project-level LLD AGENTS.md, links to root
/agents-refine --rounds N             # run N full cycles (default: 3)
/agents-refine --bootstrap            # start from Karpathy baseline if no AGENTS.md exists
/agents-refine --dry-run              # show evaluation output without writing
```

## What this skill does

Runs a structured refinement loop that mirrors your manual process:

1. **Opus evaluates** — subagent reads AGENTS.md, scores it on 6 axes (completeness, precision, enforceability, anti-pattern coverage, tech fit, LLD/HLD coherence), outputs a critique with specific gaps
2. **Patch v_n → v_n+1** — applies critique: tighten vague rules, cut redundancies, add missing constraints
3. **Codex evaluates independently** — runs `codex` CLI with a reviewer persona, no access to the Opus critique (independent signal)
4. **Patch v_n+1 → v_n+2** — applies Codex findings
5. **Opus final polish** — coherence pass: removes contradictions, normalizes format, checks HLD↔LLD alignment
6. **Write final** — overwrites AGENTS.md, prints a diff summary

## Execution protocol

### Step 0 — Detect context

```bash
# Determine mode
if [ -f AGENTS.md ]; then MODE="refine"; else MODE="bootstrap"; fi
# Detect if root (no parent AGENTS.md within 3 levels) or project
ROOT_AGENTS=$(find ../.. -maxdepth 2 -name "AGENTS.md" | head -1)
```

- If `ROOT_AGENTS` is empty → this is root/HLD mode
- If `ROOT_AGENTS` exists → this is project/LLD mode; read it first

### Step 1 — Read and version current AGENTS.md

Read the current AGENTS.md (or bootstrap from Karpathy baseline below if `--bootstrap` flag). Store as `VERSION_0`.

**Karpathy bootstrap content** (use when no AGENTS.md exists):

```
## Behavioral Rules

1. Think Before Coding — state assumptions, surface tradeoffs, ask when unclear
2. Simplicity First — minimum code that solves the problem, no speculative features
3. Surgical Changes — touch only what the request requires, match existing style
4. Goal-Driven Execution — define verifiable success criteria before starting
```

### Step 2 — Opus evaluation (spawn subagent)

Spawn an Agent with `subagent_type: general-purpose` and this prompt:

```
You are a senior engineering lead evaluating an AGENTS.md rule file.
Score it 0-10 on each axis and provide actionable critique:

AXES:
- Completeness: covers all common failure modes?
- Precision: rules are specific enough to enforce?
- Enforceability: rules are verifiable, not aspirational?
- Anti-pattern coverage: prevents the top LLM coding mistakes?
- Tech fit: matches the actual tech stack in use?
- HLD/LLD coherence: [root only] high-level enough? [project only] specific enough + references root?

For each axis score below 8, list the exact rules that fail it and write replacement text.
Output format:
SCORES: {axis: score, ...}
GAPS: [list of specific missing rules or weak rules]
REWRITES: [exact text changes]
```

Pass the full AGENTS.md content as context. Collect the critique.

### Step 3 — Apply Opus critique → VERSION_1

Apply every REWRITE from the Opus critique. Do not paraphrase — use the exact replacement text. Add missing rules from GAPS verbatim. Remove rules flagged as redundant.

### Step 4 — Codex independent evaluation

Run Codex via shell with VERSION_1 content. Write the prompt to a temp file first:

```bash
PROMPT_FILE=$(mktemp /tmp/agents-codex-XXXXXX.txt)
cat > "$PROMPT_FILE" << 'PROMPT'
You are reviewing an AGENTS.md rule file for an AI coding agent. Your job:
1. Find rules that are too vague to enforce (list them)
2. Find rules that contradict each other (list them)
3. Find missing rules for common failure modes: over-engineering, scope creep, 
   silent assumption, broken test-first discipline, style drift
4. Suggest 3-5 concrete new rules this file needs
Output a numbered list of findings only. No praise.
PROMPT

echo "--- AGENTS.md CONTENT ---" >> "$PROMPT_FILE"
cat AGENTS.md >> "$PROMPT_FILE"

codex --model o4-mini -q "$(cat $PROMPT_FILE)" 2>/dev/null
rm -f "$PROMPT_FILE"
```

Collect the numbered findings.

### Step 5 — Apply Codex findings → VERSION_2

For each Codex finding:
- Vague rule → rewrite with a concrete, binary test
- Contradiction → resolve by keeping the stricter rule
- Missing rule → add it, 1-2 sentences max, enforceable

### Step 6 — Opus final polish (spawn subagent)

Spawn a second Opus subagent for coherence:

```
Read this AGENTS.md and do a final polish pass:
1. Remove any duplicate or overlapping rules
2. Normalize formatting (consistent heading levels, bullet style)
3. Check that project-level rules don't re-state root-level rules (if LLD mode)
4. Ensure every rule has a binary test (a human can say yes/no whether it was followed)
5. Keep it under 150 lines — cut anything that doesn't pull weight

Return the complete final AGENTS.md text only. No commentary.
```

### Step 7 — Write and diff

Write VERSION_FINAL to AGENTS.md.

Print a summary:
```
Refinement complete.
  Rounds: 3 (Opus eval → Codex eval → Opus polish)
  Rules before: N  |  Rules after: M
  Lines before: X  |  Lines after: Y
  Net change: ~Z%
```

If `--dry-run`, print VERSION_FINAL to stdout instead of writing.

## LLD project mode specifics

When refining a project-level AGENTS.md:

1. Read root AGENTS.md first — treat those rules as immutable constraints
2. Open with an explicit reference:
   ```
   # Project Rules
   > Inherits from: [root AGENTS.md](../../AGENTS.md) — all root rules apply here.
   ```
3. Project rules must be *additive only*: tech-stack specifics, framework conventions, test patterns, deploy constraints
4. Any rule that would fit the root file → flag it ("Move to root: [rule]"), don't add it here
5. Codex evaluation prompt gets extra context: include tech stack (read from package.json / pyproject.toml / go.mod)

## Integration with hamel-review (`/review-loop`)

These two tools are orthogonal and complementary:

| Tool | Frequency | Scope | Loop driver |
|------|-----------|-------|-------------|
| `/agents-refine` | Every 2-4 weeks or when rules feel stale | Rule quality (meta) | You trigger manually |
| `/review-loop` | Every significant task/PR | Code quality (per task) | Stop hook, automatic |

**Workflow order:**
1. Run `/agents-refine` first to get solid rules
2. Those rules land in AGENTS.md — Codex's "Holistic Review" agent in `/review-loop` reads AGENTS.md automatically
3. Every code task runs through `/review-loop` and is judged against the refined rules
4. When `/review-loop` feedback repeatedly surfaces the same gap → that's your signal to run `/agents-refine` again

## When to re-run

Strong signals to trigger `/agents-refine`:
- `/review-loop` keeps flagging the same class of issue (rules aren't preventing it)
- You started a new project with a different tech stack
- After a major refactor that changed architectural patterns
- Monthly cadence as a default
