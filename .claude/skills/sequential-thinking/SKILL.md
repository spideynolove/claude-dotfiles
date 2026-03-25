---
name: sequential-thinking
description: Structure cognitive analysis using sequential reasoning chains via mcporter on-demand invocation
---

# Sequential Thinking (MCPorter)

Progressive disclosure framework - tools invoked only when explicitly needed.

## CRITICAL: Call Syntax

mcporter requires **function-call notation** (parentheses). The space-separated `key:value` syntax does NOT work.

```bash
# ✅ CORRECT
npx mcporter call "sequential-thinking.start_session(problem: \"My problem\", success_criteria: \"Clear answer\", session_type: \"general\")"

# ❌ WRONG — will fail with 'content is a required property'
npx mcporter call sequential-thinking.add_thought content:"My thought" confidence:0.9
```

## Core Workflow

### Phase 1: Start Session

`session_type` must be one of: `"general"` | `"coding"` | `"memory"` (NOT `"analysis"`)

```bash
npx mcporter call "sequential-thinking.start_session(problem: \"What must I answer?\", success_criteria: \"Clear understanding\", session_type: \"general\")"
```

### Phase 2: Add Thoughts

`add_thought` does NOT take `session_id` — session is implicit (one active session at a time).

```bash
npx mcporter call "sequential-thinking.add_thought(content: \"FIRST PRINCIPLE: What is this fundamentally?\", confidence: 0.9)"
```

**For long content** — write to a temp file first, then pipe:

```bash
cat > /tmp/thought.txt << 'EOF'
ANALYSIS: The system works by...
Key insight: X leads to Y because...
EOF
npx mcporter call "sequential-thinking.add_thought(content: \"$(cat /tmp/thought.txt)\", confidence: 0.85)"
```

### Phase 3: Branch for Alternative Perspectives

```bash
npx mcporter call "sequential-thinking.create_branch(name: \"conceptual-analysis\", from_thought: \"last-thought-id\", purpose: \"Understand concepts separate from implementation\")"
```

### Phase 4: Query Existing Patterns

```bash
npx mcporter call "sequential-thinking.query_memories(tags: \"architecture,patterns\", content_contains: \"auth\")"
```

### Phase 5: Store Discoveries

```bash
npx mcporter call "sequential-thinking.store_memory(content: \"Brief description\", tags: \"pattern,category\")"
```

## Common Operations

**List + resume a previous session:**
```bash
npx mcporter call "sequential-thinking.list_sessions()"
npx mcporter call "sequential-thinking.load_session(session_id: \"SESSION_ID\")"
```

**Analyze current session completeness:**
```bash
npx mcporter call "sequential-thinking.analyze_session()"
```

**Export findings to file:**
```bash
npx mcporter call "sequential-thinking.export_session(filename: \"analysis.md\", format: \"markdown\", export_type: \"session\")"
```

**Explore packages:**
```bash
npx mcporter call "sequential-thinking.explore_packages(task_description: \"Build async task queue\", language: \"python\")"
```

**Record architecture decision:**
```bash
npx mcporter call "sequential-thinking.record_decision(decision_title: \"Use Redis\", context: \"Need distributed queuing\", options_considered: \"Celery,RQ\", chosen_option: \"RQ\", rationale: \"Simpler setup\", consequences: \"No advanced routing\")"
```

## Full Tool Signatures (from `npx mcporter list sequential-thinking`)

```
start_session(problem, success_criteria, constraints?, session_type?: "general"|"coding"|"memory", codebase_context?)
add_thought(content, branch_id?, confidence?, dependencies?, explore_packages?)
create_branch(name, from_thought, purpose)
merge_branch(branch_id, target_thought?)
store_memory(content, confidence?, code_snippet?, language?, tags?)
query_memories(tags?, content_contains?)
record_decision(decision_title, context, options_considered, chosen_option, rationale, consequences)
explore_packages(task_description, language?)
export_session(filename, format?: "markdown"|"json", export_type?: "session"|"memories", tags?)
list_sessions()
load_session(session_id)
analyze_session()
```

## When to Activate

Invoke when you need:
- Deep codebase analysis before implementation
- Pattern extraction from existing code
- Complex problem decomposition
- Architecture decision documentation
- Building mental models of systems

## Anti-Patterns

❌ Space-separated `key:value` syntax — use `(param: "value")` instead
❌ Passing `session_id` to `add_thought` — session is implicit
❌ Using `session_type: "analysis"` — valid values are `general`, `coding`, `memory`
❌ Embedding multiline strings with `\n` in bash — write to temp file instead
❌ Don't load MCP in `.claude.json` alongside this skill
❌ Don't store code with comments/docstrings

## Success Pattern

✅ Always use parentheses call syntax
✅ Check `npx mcporter list sequential-thinking` if you get parameter errors
✅ Sessions stored in `memory-bank/sessions/`
✅ Patterns stored in `memory-bank/patterns/` (pure code only)
