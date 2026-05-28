# RTK - Rust Token Killer

**Scope**: High-output commands only — build, test, log, git diffs. NOT discovery or file-reading commands.

## What RTK handles (hook intercepts these)

Build, test, CI, and noisy-output commands:
- `git log`, `git diff`, `git status` — compact summaries
- `cargo build/test`, `npm run build`, `pytest`, `jest`, `vitest` — failures only
- `docker`, `kubectl`, `pnpm`, `dotnet` — stripped noise
- `tsc`, `next build`, `eslint` — grouped errors

## What RTK does NOT handle (excluded from hook)

Discovery and source-of-truth commands pass through natively:
- `find`, `ls` — file discovery: paths must be exact, no shortening
- `grep`, `rg` — content search: full context and line numbers required
- `cat`, `head`, `tail` — file reading: exact content matters
- `which`, `type`, `realpath`, `readlink`, `stat`, `file` — path/command resolution

Excluded via `[hooks] exclude_commands` in `~/.config/rtk/config.toml`.

## Meta Commands

```bash
rtk gain              # Show token savings analytics
rtk gain --history    # Show command usage history with savings
rtk proxy <cmd>       # Execute raw command without filtering (for debugging)
```

## Hook-Based Usage

The Claude Code PreToolUse hook (`rtk hook claude`) intercepts Bash commands automatically.
Discovery commands are excluded — they run natively without RTK rewriting.

Refer to CLAUDE.md for tool selection policy.
