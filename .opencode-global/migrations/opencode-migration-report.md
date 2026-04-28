# OpenCode Migration Report

**Date**: Monday, April 27, 2026
**Target**: OpenCode (v1.14.28, anomalyco/opencode, was sst/opencode)
**Source**: Claude Code (~/.claude)
**Converter Used**: `oc-convert` (https://github.com/OpeOginni/oc-convert)

---

## 1. Work Completed

### Skills (32 loaded, verified)
Used `bunx oc-convert --skills` to convert 14 personal + shared skills. The converter:
- Rewrote YAML frontmatter to OpenCode-safe keys (`name`, `description`, `compatibility`)
- Added `compatibility: claude-code` tag
- Preserved body content unchanged

| Skill Source | Count | Location | Status |
|---|---|---|---|
| Personal skills (~/.claude/skills/) | 10 | Converted → ~/.config/opencode/skills/ | Loaded |
| Shared skills (~/.agents/skills/) | 4 | Converted → ~/.config/opencode/skills/ | Loaded |
| Superpowers plugin (obra/superpowers) | 18 | Cached plugin install | Loaded |
| **Total** | **32** | | **Verified via `opencode run`** |

**Key discovery**: OpenCode natively searches `~/.claude/skills/` and `~/.agents/skills/` for Claude Code compat. Skills were discoverable *before* conversion. The converted copies in `~/.config/opencode/skills/` provide the explicit OpenCode-native path.

### Commands (10 loaded, verified)
Copied from `~/.claude/commands/` to `~/.config/opencode/commands/`.

| Command | Status |
|---|---|
| `/ccs` | Loaded |
| `/check-github-ci` | Loaded |
| `/commit-message` | Loaded |
| `/design-patterns` | Loaded |
| `/e2e` | Loaded |
| `/explain-code` | Loaded |
| `/refactor` | Loaded |
| `/semantic-commit` | Loaded |
| `/token-efficient` | Tested — responded "Token-efficient mode active" |
| `/xia-group` | Loaded |

### Instruction File (AGENTS.md, verified)
Created `~/.config/opencode/AGENTS.md` derived from `~/.claude/CLAUDE.md` with these changes:
- Stripped `@RTK.md` include syntax (not supported by OpenCode) → inlined RTK content
- Changed `Read`/`Grep`/`Glob` → `read`/`grep`/`glob` (lowercase tool names)
- Changed skill path references from `~/.claude/skills/` to skill-only references
- Verified AGENTS.md is loaded: `opencode run` confirmed "no gratitude" and "no comments" rules are active

### Plugin (superpowers, loaded)
Installed via `opencode.json`: `"plugin": ["superpowers@git+https://github.com/obra/superpowers.git"]`
This provides 18 workflow skills (TDD, debugging, brainstorming, git worktrees, etc.).

### Config File
Created `~/.config/opencode/opencode.json`:
```json
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": ["AGENTS.md"],
  "mcp": {},
  "plugin": ["superpowers@git+https://github.com/obra/superpowers.git"]
}
```

### Settings Conversion Attempt (FAILED)
`bunx oc-convert --settings ~/.claude/settings.json` failed with validation errors:
- `hooks.PreToolUse` - expected record, received array
- `hooks.PostToolUse` - expected record, received array
- `hooks.SessionStart` - expected record, received array
- Missing hooks: `Notification`, `UserPromptSubmit`, `Stop`, `SubagentStop`, `PreCompact`, `SessionEnd`

The converter's hook schema expects a different format than Claude Code's array-of-matcher-groups. This is a known gap in the converter.

---

## 2. Testing Results

| Component | Test Method | Result | Notes |
|---|---|---|---|
| Skills (32) | `opencode run "list all skills"` | **PASS** | Listed all 32 by name and description |
| Skill loading | `opencode run "load sequential-thinking"` | **PASS** | Returned core principles correctly |
| Commands (10) | `opencode debug config` → parse command keys | **PASS** | All 10 in config |
| Command execution | `opencode run "/token-efficient"` | **PASS** | Activated token-efficient mode |
| AGENTS.md | `opencode run "what are communication rules"` | **PASS** | All 5 rules recalled correctly |
| Native tools | `opencode run "check tools"` | **PASS** | bash, edit, read, write, glob, grep, task, skill, todowrite, webfetch |
| MCP servers | `opencode run "check MCP"` | **PASS** (empty) | None configured — by design |
| Plugin | `opencode debug config` → parse skills paths | **PASS** | superpowers cached and loaded |
| Hooks | N/A | **NOT MIGRATED** | See Section 4 |

---

## 3. OpenCode vs. Codex vs. Claude Code: Key Differences

| Feature | Claude Code | Codex | OpenCode |
|---|---|---|---|
| **Instruction file** | `CLAUDE.md` | `AGENTS.md` | `AGENTS.md` (falls back to `CLAUDE.md`!) |
| **Global config** | `~/.claude/settings.json` (JSON) | `~/.codex/config.toml` (TOML) | `~/.config/opencode/opencode.json` (JSON) |
| **Hook format** | JSON arrays in `settings.json` | JSON in `hooks.json` + TOML `config.toml` | **JS/TS plugin events** — no shell JSON hooks |
| **Hook events** | `PreToolUse`, `PostToolUse`, `SessionStart`, `UserPromptSubmit`, `Stop`, `SubagentStop`, `Notification`, `PreCompact` | `SessionStart`, `PreToolUse`, `PostToolUse`, `UserPromptSubmit`, `Stop`, `PermissionRequest` | `tool.execute.before`, `tool.execute.after`, `session.created`, `file.edited`, 30+ more |
| **Skills path** | `~/.claude/skills/` | `~/.codex/skills/`, `~/.agents/skills/` | `.opencode/skills/`, `~/.config/opencode/skills/`, **`~/.claude/skills/`**, **`~/.agents/skills/`** |
| **Commands** | `~/.claude/commands/*.md` | `~/.codex/commands/` | `.opencode/commands/*.md`, `~/.config/opencode/commands/` |
| **MCP config** | `settings.json` → `mcpServers` | `config.toml` `[mcp_servers.*]` | `opencode.json` → `"mcp"` |
| **Plugin system** | Marketplace JS modules | JS/TS modules | JS/TS via `@opencode-ai/plugin`, npm packages |
| **Tool names** | `Bash`, `Edit`, `Write`, `Read`, `Glob`, `Grep`, `WebFetch` | `Bash`, `apply_patch`, `Edit`, `Write` | `bash`, `edit`, `write`, `read`, `glob`, `grep`, `apply_patch`, `list`, `task`, `skill`, `todowrite`, `webfetch`, `websearch`, `question`, `lsp`, `codesearch` |
| **Multi-agent** | `Task` tool (subagents) | `max_depth=2`, `max_threads=6` in TOML | `task` tool + `@mention` agents |
| **Memory** | Per-project MEMORY.md | Native memories via `config.toml` | Per-session, compaction via plugins |
| **Token saving** | RTK hook (PreToolUse on Bash) | RTK hook | Plugin event `tool.execute.before` |

### Architecture Philosophy

| Tool | Philosophy |
|---|---|
| **Claude Code** | Full-featured, marketplace plugins, shell-based hooks |
| **Codex** | Modular optimization — mcporter for on-demand MCP, TOML config, decoupled tools |
| **OpenCode** | Claude Code compat layer + JS plugin ecosystem — most native tools built-in, skills auto-discovered from multiple paths |

---

## 4. What's NOT Migrated (Hooks)

OpenCode does NOT support Claude Code-style shell JSON hooks. All lifecycle automation must be JS/TS plugin modules.

### Claude Code hooks that need JS plugin shims:

| Hook | Claude Implementation | OpenCode Target | Status |
|---|---|---|---|
| `PreToolUse: Read\|Glob\|Grep\|WebFetch\|mcp__` → `dedup.py` | Python script in `~/.claude/hooks/` | `tool.execute.before` plugin event | **NOT MIGRATED** |
| `PreToolUse: Read` → `crg-preread.py` | Python script | `tool.execute.before` filter by `read` | **NOT MIGRATED** |
| `PreToolUse: Bash` → `rtk hook claude` | Inline shell command | `tool.execute.before` filter by `bash` | **NOT MIGRATED** |
| `PostToolUse: Edit\|Write\|Bash` → `crg update` | Inline shell command | `tool.execute.after` filter by `edit\|write\|bash` | **NOT MIGRATED** |
| `SessionStart` → `crg-session-start.py` | Python script | `session.created` plugin event | **NOT MIGRATED** |

### Required JS Plugin Structure

```typescript
// ~/.config/opencode/plugins/hooks.ts
import { execSync } from "child_process";

export default function ({ }) {
  return {
    "tool.execute.before": async (ctx: any) => {
      // dedup logic
      // rtk bash rewrite
      // crg-preread for read tool
    },
    "tool.execute.after": async (ctx: any) => {
      // crg update after edit/write/bash
    },
    "session.created": async (ctx: any) => {
      // crg-session-start
    },
  };
}
```

The existing Python scripts (`dedup.py`, `crg-preread.py`, `crg-session-start.py`) can be called from the JS plugin via `child_process.exec`. This is the remaining development work.

---

## 5. Lessons from Comparing AGENTS.md Files

### What Claude Code's CLAUDE.md has that's NOT in the current OpenCode AGENTS.md:
1. **`@RTK.md` include** — OpenCode doesn't support `@file` includes → inlined
2. **`Codex will review your output`** — tool-specific, removed
3. **Skill path references** (`~/.claude/skills/graphify/SKILL.md`) — changed to skill-only

### What Codex's AGENTS.md has that SHOULD be added to OpenCode AGENTS.md:
1. **Memory and Context section** — describes when to use memories vs skills vs MCP
2. **Multi-Agent Hierarchy** — depth/thread config, effective patterns
3. **Hooks and Token Economy** — hook policy, RTK usage, MCP registration policy
4. **Preferred tool split table** — when to use what

### Recommended additions to OpenCode AGENTS.md:
- Memory/context strategy (OpenCode has per-session + compaction)
- Tool split table (native tools vs MCP vs skill-mediated)
- Hook/token economy policy (once JS plugin is written)

---

## 6. Converter Assessment

### `oc-convert` (OpeOginni/oc-convert)
| Feature | Status |
|---|---|
| Skills conversion | **PASS** — 14/14 converted, all loaded |
| Settings/hooks conversion | **FAIL** — hook format mismatch (arrays vs records) |
| MCP conversion | Not tested (no MCP servers configured) |
| Agent conversion | Not tested (no agents in ~/.claude/agents/) |

### `alirezarezvani/claude-skills/scripts/convert.sh --tool opencode`
- Alternative for bulk community skill conversion
- Outputs to `integrations/opencode/skills/` with `compatibility: opencode` frontmatter
- Did not test (oc-convert was sufficient for personal skills)

---

## 7. Files Installed

| File | Purpose |
|---|---|
| `~/.config/opencode/opencode.json` | Main config (schema, instructions, MCP, plugin) |
| `~/.config/opencode/AGENTS.md` | Global behavior instructions |
| `~/.config/opencode/skills/*/SKILL.md` (14 dirs) | Converted personal + shared skills |
| `~/.config/opencode/commands/*.md` (10 files) | Custom slash commands |
| `~/.config/opencode/package.json` | Plugin dependency (@opencode-ai/plugin) |

---

## 8. Next Steps

1. **Write JS hooks plugin** — translate 5 shell hooks to `tool.execute.before`/`tool.execute.after`/`session.created` events
2. **Add memory/context strategy** to AGENTS.md (learn from Codex AGENTS.md pattern)
3. **Add MCP servers** to `opencode.json` when needed (code-review-graph, sequential-thinking)
4. **Update `.opencode-global/` in claude-dotfiles** — symlink or copy for cross-PC sync
5. **Test with `opencode plugin install superpowers`** — may be cleaner than git URL
