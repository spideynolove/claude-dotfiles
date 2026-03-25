# /xia-group — Sequential Group Distillation

**Purpose:** Run `/xia` rounds against a ranked list of repos, using the codebase itself as the running distillation. Each round absorbs only what the previous rounds haven't already covered.

**Core rule:** You never compare two external repos directly. The codebase is always side A. Each round updates A before the next comparison begins.

---

## Usage

```
/xia-group <group-name> <repo1> <repo2> ... [--focus <topic>]
```

- `<group-name>`: label for this group run (e.g. `autonomous-loops`)
- `<repo1> <repo2> ...`: repos in order — richest/most complex first, simplest last
- `--focus <topic>`: optional, passed to each `/xia` round as its focus

**Example:**

```
/xia-group autonomous-loops ralph-claude-code ralphex ralphy sleepless-agent claude-auto-resume --focus loop
```

## Storage

Group state is stored alongside xia patterns:

```
<project-root>/
└── .claude/
    └── xia/
        ├── XIALOGUE.md
        ├── groups/
        │   └── xia-group-[name].md   ← group progress file
        └── patterns/
            └── xia-[repo-slug]-[pattern].md
```

---

## Ordering Rule

**Before running any round**, sort the repo list:

1. Richest/most complex first (most patterns, highest token count)
2. Simplest/most specific last

Rationale: by round N, the simple repos will mostly register as "already covered" — which is the signal that distillation is working.

---

## Phase G0 — Group Init

**Commands:**

```bash
# 1. Check for prior group state
cat .claude/xia/groups/xia-group-$GROUP_NAME.md 2>/dev/null || echo "GROUP_MISSING"
```

```bash
# 2. Check prior XIALOGUE state
cat .claude/xia/XIALOGUE.md 2>/dev/null || echo "XIALOGUE_MISSING"
```

**If GROUP_MISSING**, create `.claude/xia/groups/xia-group-[name].md` with this exact structure:

```markdown
# Group: [name]
**Focus:** [focus or "none"]
**Started:** [YYYY-MM-DD]

## Round Log

| Round | Repo | Status | Borrowed | Already Covered | Skipped |
|-------|------|--------|----------|-----------------|---------|

## Remaining
[ordered repo list, one per line]
```

**Required output — print exactly:**

```
## Phase G0 — Group Init

**Group:** [name]
**Focus:** [focus or none]
**Repos in order:** [numbered list]
**Prior rounds completed:** [0 / N — list repos done]
**Resuming from:** [Round N+1: repo-name / fresh start]
```

---

## Phase GN — Round N

For each repo in order, run the full `/xia` protocol (Phases 0–6).

**Before starting each round, print:**

```
## Round [N] of [total] — [repo]

Codebase state: [one sentence from XIALOGUE.md evolved state]
Running /xia now...
```

Then execute `/xia <repo> [focus]` — all phases 0–6 exactly as defined in `xia.md`.

**Phase 3 dialogue still happens** — do not skip or auto-confirm it. User must confirm which gaps to borrow before Phase 4 proceeds.

---

## Phase GN-Debrief — Round Debrief

After Phase 6 of each `/xia` round completes, output this block:

```
## Round [N] Debrief — [repo]

**Borrowed:** [list of patterns absorbed]
**Already covered:** [gaps B had that A already handles — from Phase 2 table]
**Skipped:** [gaps with High friction or user-skipped]
**Absorption rate:** [borrowed / (borrowed + already-covered + skipped) * 100]%
**Cumulative absorption:** [total borrowed across all rounds so far]
```

Then update the group file — append one row to the Round Log:

```
| [N] | [repo] | complete | [borrowed patterns] | [already-covered count] | [skipped count] |
```

And remove the repo from the Remaining list.

---

## Phase GN-Gate — Continue?

After each debrief, print this block and **wait for user response**:

```
## Continue to Round [N+1]?

**Next repo:** [repo-name]
**Remaining after that:** [list]

The codebase has absorbed [N] patterns so far. Next round will compare against this updated state.

Proceed? (yes / skip [repo] / stop)
```

- `yes` → start Round N+1
- `skip [repo]` → mark repo as skipped in group file, move to N+2
- `stop` → jump to Phase GZ

Do not start the next round without explicit user confirmation.

---

## Phase GZ — Group Complete

After all rounds finish (or user stops), print:

```
## Xỉa Group Complete — [group-name]

**Rounds completed:** [N] of [total]
**Total patterns borrowed:** [list]
**Absorption by round:**
  Round 1 ([repo]): [N] borrowed, [N] already covered → [rate]%
  Round 2 ([repo]): [N] borrowed, [N] already covered → [rate]%
  ...

**Distillation result:** [one sentence — what the codebase can do now that it couldn't before]
**Diminishing returns started at:** [Round N — first round where already-covered > borrowed]
```

Then commit the group file:

```bash
git add .claude/xia/groups/
git commit -m "xia-group: complete [group-name] — [N] patterns absorbed"
```

---

## Resuming an Interrupted Group

If Phase G0 finds an existing group file with remaining repos, resume from the next incomplete round. Print the full group state, then ask:

```
## Resuming Group: [name]

**Completed:** [repos done]
**Remaining:** [repos left]
**Next:** Round [N] — [repo]

Resume? (yes / reorder / stop)
```

`reorder` lets the user change the remaining sequence before continuing.
