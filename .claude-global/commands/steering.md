---
description: Bootstrap or sync .claude/steering/ as persistent project memory
argument-hint: "[--sync]"
---

# /steering — Project Memory Management

Maintain `.claude/steering/` as persistent project knowledge loaded by every planning command.

**Three files:** `product.md` (purpose/value/non-goals) · `tech.md` (stack/decisions/conventions) · `structure.md` (layout/naming/imports)

## Scenario Detection

Check `.claude/steering/` status:
- **Bootstrap**: Empty or missing core files → generate from codebase
- **Sync** (`--sync` or files exist): Update to match current code state

---

## Bootstrap Flow

1. Analyze codebase to extract patterns:
   ```bash
   # Understand structure
   find . -maxdepth 3 -type f -name "*.json" | grep -E "package|pyproject|go.mod" | head -5
   ls src/ 2>/dev/null || ls app/ 2>/dev/null || ls lib/ 2>/dev/null
   ```
   Read: README, package.json/pyproject.toml/go.mod, 2-3 source files for conventions

2. Generate 3 files from templates in `32-cc-sdd-patterns/steering-templates/`:
   - `product.md` — purpose, core value, user types, non-goals
   - `tech.md` — stack table, architectural decisions, coding conventions
   - `structure.md` — directory pattern, naming, imports

3. **Golden rule**: Document patterns, not catalogs.
   - ❌ "List every file in src/"
   - ✅ "Feature-first layout: each feature owns its components, hooks, and tests"

4. Present summary for user review.

---

## Sync Flow

1. Read all existing `.claude/steering/*.md`
2. Detect drift:
   - New framework/library added → update `tech.md`
   - New directory pattern → update `structure.md`
   - Scope changed → update `product.md`
3. Update **additively** — add sections, never replace user content
4. Report: what changed, what drifted, what to consider

---

## Usage in Planning

Every planning command (create_plan, implement_plan, etc.) should read steering first:

```
Read .claude/steering/product.md, tech.md, structure.md before planning.
```

This gives consistent project memory across sessions without loading the full codebase each time.

---

## Output Format

```
✅ Steering [Created/Updated]

Generated:
- product.md: [1-line summary]
- tech.md: [key stack]
- structure.md: [organization pattern]

Review and treat as source of truth for planning sessions.
```
