# Context-Mode Workflow Guide

## The Problem With the Old Strategy

Your previous approach:
- Split work into tasks, one session per task (divide and conquer)
- Monitor context via claude-hud; at ~60% → `/compact` or `/simplify`
- Risk: after `/compact`, Claude loses working state — which files were being edited, what decisions were made, what's in progress

This worked, but it was **manual context triage** — you were doing the job context-mode automates.

---

## What Changes With Context-Mode

Context-mode attacks the problem at three levels simultaneously:

### 1. Context Saving (automatic)
The PreToolUse/PostToolUse hooks intercept tool calls that would dump raw data into context and reroute them through sandbox tools. A Playwright snapshot that would cost 56KB becomes ~300 bytes in context. You don't do anything — the hooks enforce this automatically on Claude Code.

**Impact on your workflow:** Context fills up slower. The 60% threshold arrives much later, or not at all on medium tasks.

### 2. Session Continuity (automatic on `/compact`)
Before compaction, the PreCompact hook runs: every file edit, git operation, task, decision, and error from the session is indexed into SQLite FTS5. After compaction, context-mode retrieves only what's relevant via BM25 search — not a full dump. Claude picks up exactly where it left off.

**Impact on your workflow:** `/compact` is no longer destructive. You don't need to split tasks preemptively just to avoid losing state after compaction.

### 3. Think in Code (behavioral shift — requires your guidance)
Instead of: "read 20 files → reason over them"
Do: "write a script that analyzes those 20 files → log only the result"

This is the biggest paradigm shift and the one that requires deliberate prompting.

---

## New Session Strategy

### Starting a Session

```
claude --continue   # resumes previous session with full indexed state
claude              # fresh session, previous state deleted
```

Use `--continue` whenever you're resuming a task mid-way. Without it, the previous session's SQLite index is wiped — intentional clean slate behavior.

### Context Monitoring

Keep using claude-hud. The thresholds shift:

| Old threshold | New threshold | Reason |
|---|---|---|
| 60% → consider /compact | 80%+ → consider /compact | Sandbox tools reduce per-operation cost |
| /compact loses state | /compact is safe | PreCompact hook indexes everything first |
| Split task before 60% | Split only if logically separate | State survives compaction |

### When to Still Split Tasks

Split into separate sessions when tasks are **logically independent**, not because you fear context loss. Examples:

- Feature A and Feature B have no shared state → separate sessions
- Research phase vs. implementation phase → separate sessions (or use `--continue`)
- Different codebases entirely → separate sessions

Don't split just because a task is long. Let context-mode handle the continuity.

---

## Optimized Slash Command Workflows

### `/context-mode:ctx-stats`
**When:** Any time you're curious how much context has been saved. Run it instead of eyeballing claude-hud when you want hard numbers.

```
/context-mode:ctx-stats
```
Shows: tokens consumed, savings ratio, per-tool breakdown. If savings ratio is low, you or Claude may be bypassing sandbox tools (using Bash for large outputs instead of ctx_execute).

### `/context-mode:ctx-doctor`
**When:** Start of any new session where context-mode behavior seems off — missing hooks, tools not routing correctly.

```
/context-mode:ctx-doctor
```
Validates: runtimes, hooks registered, FTS5, plugin version. Run this if claude-hud shows context climbing unusually fast (hooks may have broken).

### `/context-mode:ctx-insight`
**When:** Weekly or after heavy sessions. Opens a browser dashboard showing 15+ personal metrics — tool usage patterns, session activity, error rate, parallel work patterns.

```
/context-mode:ctx-insight
```
Use it to identify which tool calls are eating the most context, then target those for "think in code" refactoring.

### `/context-mode:ctx-upgrade`
**When:** Before starting a large task, or when ctx-doctor reports a version mismatch.

```
/context-mode:ctx-upgrade
```
Pulls latest, rebuilds, migrates cache, fixes hooks. Safe to run mid-project.

### `/context-mode:ctx-purge`
**When:** You want a guaranteed clean slate — no residual indexed state from previous sessions.

```
/context-mode:ctx-purge
```
Destructive. Use before switching to a completely different project domain.

---

## The "Think in Code" Workflow

This is where the largest gains come from. Instead of asking Claude to read and reason over raw data, prompt it to write analysis scripts.

### Old pattern (avoid)
```
Read src/auth.ts, src/user.ts, src/session.ts and tell me which functions call refreshToken
```
→ 3 full file dumps into context, Claude reasons over raw text

### New pattern (use)
```
Write a shell script using tilth_search or grep to find all call sites of refreshToken across the codebase. Execute it via ctx_execute and give me only the result.
```
→ Script runs in sandbox, only stdout enters context

### Prompting template
When you need analysis across multiple files:
```
Don't read the files directly. Write a [language] script that [does the analysis] and prints only the summary. Run it with ctx_execute.
```

When you need to process a URL or external data:
```
Use ctx_fetch_and_index to fetch [url], then ctx_search to find [what you need]. Don't dump the raw content.
```

---

## Combined Workflow: Long Task With Context-Mode

### Starting
```bash
claude --continue   # if resuming; claude for fresh start
```

Tell Claude at the start of any complex task:
```
Use ctx_execute for any analysis that would produce large output. Use ctx_batch_execute to combine multiple checks. Don't read files you don't need to edit.
```

### During the Task
- Watch claude-hud; intervention threshold is now ~80%, not 60%
- If context climbs fast → run `/context-mode:ctx-stats` to see which tools are causing it
- If a tool is bypassing sandbox → redirect: "use ctx_execute for that instead of Bash"

### Before Compaction (if needed)
Just run `/compact` normally. The PreCompact hook fires automatically, indexes the session state, and Claude resumes with full awareness of what was in progress.

After compaction, if Claude seems disoriented:
```
What's the current task state? Use ctx_search to check recent session events.
```

### Ending a Session
If you'll resume later:
```bash
# Just close — state is already indexed
# Next session:
claude --continue
```

If truly done:
```bash
claude   # fresh start, previous state cleared
# or: /context-mode:ctx-purge for explicit wipe
```

---

## What Stays the Same

- claude-hud for real-time context monitoring
- `/simplify` for code quality passes (unrelated to context management)
- Logical task splitting for independent work streams
- tilth for code reading/search (complements context-mode, different role)

## What's Eliminated

- Splitting tasks preemptively to avoid state loss after `/compact`
- Manual "remind Claude of the current state" after compaction
- Worrying that 60% context means the session must end
