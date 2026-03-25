# /xia — Borrow and Adapt from GitHub Projects

**Xỉa** (Vietnamese): borrow/take something from others and use it in your own product.

This is a **protocol**, not a workflow description. Follow each phase exactly. Output templates are mandatory — fill them in, do not paraphrase or reformat them.

---

## CONSTRAINTS — Read before writing any code

**Step 1: Read the project coding rules.**

```
Read(file_path: "~/.claude/CLAUDE.md")
```

Extract and list every coding constraint found. These apply to ALL code written in this session. Common rules include: no docstrings, no comments, specific formatting, test requirements.

**Step 2: Confirm constraints before proceeding.**

Output this block exactly:

```
## Constraints active for this session
- [list each rule from CLAUDE.md, one per line]
```

Do not skip this. Do not proceed to Phase 0 until this block is printed.

---

## Usage

```
/xia <github-repo> [focus]
```

- `<github-repo>`: GitHub URL or `user/repo` shorthand
- `[focus]`: Optional — specific aspect to focus on

## Storage

Xỉa state is **project-local**, stored inside the repo and committed to git:

```
<project-root>/
└── .claude/
    └── xia/
        ├── XIALOGUE.md
        └── patterns/
            └── xia-[repo-slug]-[pattern].md
```

---

## Phase 0 — Know A

**Input:** current working directory

**Commands — run in this order:**

```bash
# 1. Check prior Xỉa state
cat .claude/xia/XIALOGUE.md 2>/dev/null || echo "XIALOGUE_MISSING"
```

```bash
# 2. Pack local codebase
npx mcporter call "repomix.pack_codebase(directory: \".\", compress: true)"
# → note the outputFilePath, use Read tool to read it
```

```bash
# 3. Start sequential-thinking session
npx mcporter call "sequential-thinking.start_session(problem: \"What does A currently do, and where are its gaps relative to the focus: $ARGUMENTS?\", success_criteria: \"Gap list for comparison against B\", session_type: \"coding\")"
```

```bash
# 4. Add one thought cataloguing A's capabilities and known gaps
npx mcporter call "sequential-thinking.add_thought(content: \"A CAPABILITIES: [list]. A GAPS: [list based on codebase read].\", confidence: 0.9)"
```

**Required output — print exactly:**

```
## Phase 0 — State of A
**Prior Xỉa sessions:** [none / N sessions, last: YYYY-MM-DD]
**Evolved state:** [one sentence from XIALOGUE.md summary, or "fresh codebase"]
**Identified gaps:** [bullet list, 3-5 items]
```

---

## Phase 1 — Ingest B

**Input:** `$ARGUMENTS` (repo + optional focus)

**Commands:**

```bash
npx mcporter call "repomix.pack_remote_repository(remote: \"<repo>\", compress: true)"
# → note the outputFilePath
Read(file_path: "<outputFilePath>")
```

If focus keyword given, also grep:
```bash
Grep(pattern: "<focus>", path: "<outputFilePath>")
```

**Required output:**

```
## Phase 1 — B Ingested
**Repo:** [repo URL]
**Size:** [token count from repomix header]
**Focus grep hits:** [N matches / not applicable]
```

---

## Phase 2 — Gap Analysis

**Commands:**

```bash
npx mcporter call "sequential-thinking.create_branch(name: \"gap-analysis\", from_thought: \"<last-thought-id>\", purpose: \"Compare A vs B capabilities\")"

npx mcporter call "sequential-thinking.add_thought(content: \"B SOLVES BUT A LACKS: [list]. A ALREADY HANDLES: [list]. INTEGRATION FRICTION: [per candidate: low/medium/high + reason].\", confidence: 0.9)"
```

**Required output — this exact table, no substitutions:**

```
## Phase 2 — Gap Analysis

| Gap in A | B's solution | Friction | Verdict |
|----------|-------------|----------|---------|
| [gap]    | [how B solves it] | Low/Med/High | Borrow / Skip |
| ...      | ...         | ...      | ...     |
```

Score friction as: **Low** = drops in cleanly, **Med** = needs adaptation, **High** = conflicts with A's existing patterns.

---

## Phase 3 — Dialogue

Print this block, then **wait for user response before continuing**:

```
## Phase 3 — Xỉa Targets

**A lacks (vs B):**
- [gap 1] — B solves this with [approach] — friction: [Low/Med/High]
- [gap 2] — ...

**Recommended first borrow:** [gap with best value/friction ratio]
**Skip for now:** [gaps with High friction + reason]

Confirm? Or specify which gap to focus on.
```

Do not proceed to Phase 4 until user confirms.

---

## Phase 4 — Adapt

**Constraints check:** Re-read the constraints listed at the top of this session. Every line of adapted code must comply.

If GitNexus is indexed (`.gitnexus/` exists):

```bash
gitnexus_query --symbol "<relevant-local-symbol>"
gitnexus_impact --symbol "<symbol-to-be-changed>" --depth 2
```

Adapt the chosen pattern:
- Apply constraints from CLAUDE.md (no comments, no docstrings, etc.)
- Rename to match A's naming conventions
- Strip what doesn't apply to A's context

**Required output:**

```
## Phase 4 — Adaptation Plan

**Seam:** [where in A this attaches — file:line or module]
**Changes to A:** [what files change and how]
**Constraints applied:** [list each CLAUDE.md rule and how it was applied]
```

---

## Phase 5 — Save

Write to `.claude/xia/patterns/xia-[repo-slug]-[pattern].md`.

**The file must use this exact template:**

```markdown
---
source: https://github.com/[repo]
extracted: [YYYY-MM-DD]
---

# [Pattern Name] from [repo]

**Gap filled:** [what A was missing]
**Constraints applied:** [list from CLAUDE.md]

## Pattern

[code only — no comments, no docstrings, per CLAUDE.md rules]

## Seam

[where in A this attaches]

## Delta from original

[what was changed and why]
```

---

## Phase 6 — Log

**If `.claude/xia/XIALOGUE.md` does not exist**, create it with this exact structure:

```markdown
# XIALOGUE — [project name from package.json or directory name]

## Current evolved state of A

[One paragraph — present tense — what A can do now including this borrow.]

---

## Borrow history

| Date | Source | Pattern | Gap filled | File |
|------|--------|---------|------------|------|
```

**If it exists**, do two things:

1. Rewrite the "Current evolved state of A" paragraph to include this borrow
2. Append one row to the table:

```
| [YYYY-MM-DD] | [repo] | [pattern name] | [gap filled] | .claude/xia/patterns/[filename] |
```

**Then commit:**

```bash
git add .claude/xia/
git commit -m "xia: borrow [pattern] from [repo]"
```

**Required output:**

```
## Phase 6 — Complete

**XIALOGUE.md:** [created / updated]
**Pattern saved:** .claude/xia/patterns/[filename]
**Committed:** [yes / pending — run: git add .claude/xia/ && git commit -m "xia: borrow [pattern] from [repo]"]
```

---

## Session summary format

After Phase 6, always print:

```
## Xỉa Session Complete

**Repo:** [B]
**Borrowed:** [pattern name]
**Gap filled:** [one line]
**Files changed:** [list]
**Next target:** [next gap from Phase 2 table, if any]
```

This summary format is fixed. Do not add or remove sections.
