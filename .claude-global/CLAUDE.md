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

Codex will review your output once you are done.

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

## Forbidden Libraries

- NEVER use PyTorch, TensorFlow, or any deep learning framework
- This machine has NO GPU — installing these libraries is wasteful and pointless
- For image processing: use ImageMagick, Pillow, or OpenCV
- For data/ML tasks: use scikit-learn, numpy, pandas

## Common Env

### Local Python Dev
- `source ~/env/.venv/bin/activate` before using `python`
- `uv pip install xxx` before any new package installations.

### SQLite
- The `sqlite3` CLI is NOT installed on this machine. Do not call it — it will fail with `command not found`.
- A `.db` file is just a file. Use Python's built-in `sqlite3` module instead, e.g. `python3 -c "import sqlite3; c=sqlite3.connect('foo.db'); print(c.execute('SELECT COUNT(*) FROM t').fetchone())"`.
- This applies to every SQLite project regardless of repo. Default to Python; never reach for the CLI.

## Security

Before any commit:
- No hardcoded secrets — use environment variables only
- Validate all user inputs at system boundaries
- Parameterized queries (no string interpolation in SQL)
- Sanitize HTML outputs (XSS prevention)
- Error messages must not leak internal state

@RTK.md

## Web Fetching

Priority order — always try earlier options first:
1. `ctx_fetch_and_index` (context-mode) — 24h TTL cache, keeps raw HTML out of context
2. `lightpanda` skill — for JS-heavy or bot-blocking sites
3. `playwright` skill — for interactive pages requiring clicks/auth
4. `WebFetch` — last resort only for known static pages

Never use `WebFetch` as the first attempt for an unknown site.

## code-review-graph: review / refactor / impact activation

**For code review, refactor planning, or impact analysis, START with code-review-graph,
not git diff or raw file reads.** On a review/refactor/impact prompt, a hook injects
code-review-graph's first-pass change analysis (`detect-changes --brief`) into context.
Treat that injected summary as your starting point.

**Routing rule:**
1. Use code-review-graph tooling to identify the risky files, functions, callers, and
   affected tests — the injected brief, plus the CLI (`code-review-graph detect-changes`,
   `code-review-graph status`) or mcporter/MCP graph tools if registered on this agent.
2. Hand the narrowed files/symbols to **tilth** (`tilth_read`, `tilth_search`) for precise
   reading.
3. `git diff` remains valid **after** CRG has identified the risky areas — it is not
   forbidden, just not the first-pass tool.

**Boundary:** tilth owns normal code reading/search. code-review-graph owns review,
impact, dependency relationships, and architecture questions. Do not call code-review-graph
for ordinary file/symbol exploration.

If the injected context says the graph is unavailable, run `code-review-graph build` once,
then proceed.
