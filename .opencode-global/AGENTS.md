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

## Security

Before any commit:
- No hardcoded secrets — use environment variables only
- Validate all user inputs at system boundaries
- Parameterized queries (no string interpolation in SQL)
- Sanitize HTML outputs (XSS prevention)
- Error messages must not leak internal state

## RTK - Rust Token Killer

**Scope**: Build, test, log, git diffs only. Discovery commands must run natively.

Use `rtk` for noisy output commands:
- `rtk git log`, `rtk npm run build`, `rtk pytest -q`, `rtk docker ps`

Do NOT use `rtk` for discovery — paths and content must be exact:
- `find`, `ls`, `grep`, `cat`, `head`, `tail`, `which`, `realpath`

Meta commands:
- `rtk gain` — token savings analytics
- `rtk proxy <cmd>` — run raw command without filtering

## code-review-graph

When the `code-review-graph` MCP is connected, use its tools **before** `read`/`grep`/`glob`:
- `semantic_search_nodes` — find functions/classes by name or keyword
- `query_graph` — trace callers, callees, imports, test coverage
- `get_impact_radius` — understand blast radius before editing
- `get_architecture_overview` — orient yourself in an unfamiliar codebase

Fall back to `read`/`grep` only when the graph doesn't cover what you need.

---

# OpenCode Agent Configuration

## Memory and Context

Use native OpenCode session context for within-session continuity.

Use skills for on-demand workflows instead of keeping MCP servers registered by default. Prefer `~/.agents/skills/<name>/SKILL.md` for shared user skills, `~/.config/opencode/skills/<name>/SKILL.md` for OpenCode-specific skills.

Use mcporter when a skill needs MCP-backed tools without exposing that MCP server directly to OpenCode.

Current preferred split:

| Situation | Use |
|-----------|-----|
| User preferences, recurring repo patterns | AGENTS.md rules |
| Structured reasoning and branch exploration | `sequential-thinking` skill |
| Browser automation | `playwright` skill through mcporter |
| Code graph context and impact analysis | `code-review-graph` CLI or mcporter skill |
| Broad repo packing | `repomix` skill |

---

## Tool Economy

OpenCode exposes these native tools: `bash`, `edit`, `write`, `read`, `glob`, `grep`, `apply_patch`, `list`, `task`, `skill`, `todowrite`, `webfetch`, `websearch`, `question`, `lsp`, `codesearch`.

Do not register MCP servers natively just to access occasional tools. Put the workflow in a skill and call it through CLI or mcporter.

---

## Hooks and Token Economy

OpenCode hooks are JS/TS plugin events, not shell JSON hooks.

Current hook policy (pending JS plugin implementation):

| Event | Purpose |
|-------|---------|
| `session.created` | Load or build code-review-graph context |
| `tool.execute.before` | Run duplicate-call guard and RTK rewrite (build/test/log only) |
| `tool.execute.after` | Update code-review-graph after edit/write/bash |

Use RTK for noisy output commands only. Discovery commands (`find`, `ls`, `grep`, etc.) must run natively — RTK compression loses semantic precision needed for correct path and content resolution.

`code-review-graph` and RTK are required baseline tools for this environment.

---
