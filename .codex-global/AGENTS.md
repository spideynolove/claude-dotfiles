# Communication Rules

## Acknowledging Feedback

When feedback IS correct:

✅ "Fixed. [Brief description of what changed]"
✅ "Good catch - [specific issue]. Fixed in [location]."
✅ "[Just fix it and show in the code]"

❌ "You're absolutely right!"
❌ "Great point!"
❌ "Thanks for catching that!"
❌ "Thanks for [anything]"
❌ ANY gratitude expression

**Why no thanks:** Actions speak. Just fix it. The code itself shows you heard the feedback.

**If you catch yourself about to write "Thanks":** DELETE IT. State the fix instead.

## Correcting Your Pushback

If you pushed back and were wrong:

✅ "You were right - I checked [X] and it does [Y]. Implementing now."
✅ "Verified this and you're correct. My initial understanding was wrong because [reason]. Fixing."

❌ Long apology
❌ Defending why you pushed back
❌ Over-explaining

State the correction factually and move on.

## Code Changes
- Clean, minimal code only
- No Docstrings or Comments - Anywhere                                                                
  - ❌ Docstrings in code                                                                             
  - ❌ Comments in code                                                                               
  - ❌ Docstrings in chat/code blocks                                                                 
  - ❌ Comments in chat/code blocks

## Git Commits
- NEVER create git commits automatically after completing a task
- ONLY commit when explicitly asked by the user
- Do not suggest committing unless the user asks

## Common Env

### Local Python Dev
- `source ~/env/.venv/bin/activate` before using `python`
- `uv pip install xxx` before any new package installations.

---

# Codex Agent Configuration

## Memory and Context

Use native Codex memories for cross-session continuity.

`memories = true` with `generate_memories` and `use_memories` in `config.toml`.

Use skills for on-demand workflows instead of keeping local MCP servers registered by default. Prefer `~/.agents/skills/<name>/SKILL.md` for user skills.

Use mcporter when a skill needs MCP-backed tools without exposing that MCP server directly to Codex.

Current preferred split:

| Situation | Use |
|-----------|-----|
| User preferences, recurring repo patterns, prior decisions | Native Codex memories |
| Structured reasoning and branch exploration | `sequential-thinking` skill |
| Browser automation without native MCP token overhead | `playwright` skill through mcporter |
| Code graph context and impact analysis | `code-review-graph` CLI or mcporter skill |
| Broad repo packing | `repomix` skill |
| Persistent graph memory | Do not use `mcp-knowledge-graph` unless explicitly requested |

---

## Multi-Agent Hierarchy

Config: `max_depth = 2`, `max_threads = 6`

Enables a 3-tier tree: Main → Coordinators (up to 6) → Workers (each coordinator spawns its own).

### Effective patterns

**Parallel research**: Spawn N agents each scoped to a different part of the codebase. Main synthesizes.

**Spec → Implement → Review pipeline**:
- Agent 1: write spec/plan
- Agent 2: implement (receives spec)
- Agent 3: review (receives both)

**Domain isolation**: Keep write scopes separate. Never run write-capable agents in parallel against the same files.

### Thread budget
6 threads = safe for most API rate limits. Only increase for pure read/research tasks. Never run write-capable agents in parallel against the same files.

### depth = 2 vs depth = 1
- depth 1 (flat): all sub-agents are peers, no further delegation
- depth 2 (this config): coordinators can spawn workers — task decomposition *within* sub-agents
- depth 3+: coordination overhead exceeds benefit in most cases

---

## js_repl Use Cases

- Parse and transform JSON tool outputs inline
- Batch multiple tool calls in one turn
- Data filtering/manipulation before acting on results
- Quick calculations without spawning a subprocess

## Web Fetching

Priority order for unknown sites:
- Use `ctx_fetch_and_index` when context-mode is available.
- Use the `lightpanda` skill for JS-heavy or bot-blocking pages.
- Use the `playwright` skill for interactive pages requiring clicks or auth.
- Use plain fetch tools only for known static pages.

Do not make a plain fetch the first attempt for an unknown site.

## Hooks and Token Economy

Codex hooks are enabled with `codex_hooks = true`.

Global hooks live in `~/.codex/hooks.json` and `~/.codex/hooks/`.

Current hook policy:

| Event | Purpose |
|-------|---------|
| `SessionStart` | Load or build code-review-graph context |
| `PreToolUse` | Run duplicate-call guard and RTK Bash rewrite hook |
| `PostToolUse` | Update code-review-graph after Bash or apply_patch edits |
| `UserPromptSubmit` | Inject code-review-graph change analysis on review/refactor/impact prompts; record context-mode prompt context |

Prefer RTK wrappers for noisy commands when they preserve the needed evidence.

Do not register local MCP servers natively in Codex just to access occasional tools. Put the workflow in a skill and call it through CLI or mcporter.

`code-review-graph` and RTK are required baseline tools for this environment.

## code-review-graph: review / refactor / impact activation

For code review, refactor planning, or impact analysis, START with code-review-graph, not
git diff or raw file reads. On a review/refactor/impact prompt, the `UserPromptSubmit` hook
injects `code-review-graph detect-changes --brief` into context — treat it as your starting
point.

Routing rule:
1. Use code-review-graph tooling (the injected brief, the `code-review-graph` CLI, or the
   mcporter skill) to identify risky files, functions, callers, and affected tests.
2. Hand the narrowed files/symbols to tilth (`tilth_read`, `tilth_search`) for precise
   reading.
3. `git diff` is valid after CRG identifies the risky areas — not first.

Do not call code-review-graph for ordinary file/symbol exploration; that is tilth's job. If
the injected context says the graph is unavailable, run `code-review-graph build` once.

@~/.codex/RTK.md
