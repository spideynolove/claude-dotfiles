# Claude Code Extension System — Study Plan

Master the official extension system from first principles before adopting third-party tooling.

---

## The component hierarchy

```
Claude Code
│
├── CLAUDE.md          → behavioral rules injected every session
├── settings.json      → model, permissions, hooks, plugins, env
│
├── commands/          → slash commands (/name)
├── skills/            → reusable prompts (auto-invocable)
├── agents/            → isolated subagents with own tools/permissions
├── hooks/             → lifecycle scripts (fire on events)
└── plugins/           → bundles of the above + MCP + LSP
```

---

## Phase 1 — Foundation (master before anything else)

| Topic | What to learn | Key file |
|---|---|---|
| CLAUDE.md hierarchy | global (`~/.claude/`) > project (`.claude/`) > directory-level; `@import` syntax; `paths:` scoping | `~/.claude/CLAUDE.md` |
| settings.json scopes | user > project > local; what merges vs what overrides | `.claude/settings.json` |
| Permissions model | `defaultMode`, `allow`/`deny` rules, `bypassPermissions` | settings.json `permissions` |
| Built-in slash commands | `/help`, `/config`, `/clear`, `/compact`, `/agents`, `/plugin` | run in terminal |

**Gate:** You can explain what happens when Claude Code starts a session — which files load, in what order, and why.

---

## Phase 2 — Commands and Skills

```
Command (.claude/commands/name.md)        Skill (.claude/skills/name/SKILL.md)
─────────────────────────────────         ──────────────────────────────────
Entry point only                          Full execution logic lives here
Thin wrapper is fine                      Required: name + description frontmatter
No auto-invocation                        Auto-invocable when description matches
No context: fork                          Can run in isolated subagent (context: fork)
No argument-hint required                 argument-hint populates autocomplete
```

### Commands

| Frontmatter field | Required | Purpose |
|---|---|---|
| `description` | Recommended | Populates tooltip in `/` menu |
| `model` | No | Override model for this command |
| `argument-hint` | No | Autocomplete hint e.g. `[filename]` |

Minimal valid command:
```markdown
---
description: What this command does.
---

Command body here. Use $ARGUMENTS for user input.
```

**Rule:** Commands that have a corresponding skill should be thin wrappers:
```markdown
Invoke: `Skill(skill="name", args="$ARGUMENTS")`
```

### Skills

| Frontmatter field | Required | Purpose |
|---|---|---|
| `name` | Yes | Identifier used in `Skill(skill="name")` |
| `description` | Yes | Claude reads this to decide when to auto-invoke |
| `argument-hint` | No | Autocomplete hint |
| `context` | No | `fork` = runs in isolated subagent |
| `agent` | No | Which subagent type when `context: fork` |
| `allowed-tools` | No | Restrict tools available to this skill |
| `model` | No | Override model |
| `effort` | No | `low` / `medium` / `high` / `max` |
| `user-invocable` | No | `false` = hide from `/` menu (Claude-only invocation) |
| `disable-model-invocation` | No | `true` = only manual invocation |
| `paths` | No | Glob patterns — skill loads only in matching directories |
| `targets` | No | (custom) Which CLIs to sync to via sync-to-codex |

**Without `name` and `description`: the skill is documentation, not a tool. Claude cannot invoke it.**

### String substitutions in skills and commands

| Variable | Value |
|---|---|
| `$ARGUMENTS` | All text after the command name |
| `$ARGUMENTS[0]` or `$0` | First argument |
| `${CLAUDE_SESSION_ID}` | Current session ID |
| `${CLAUDE_SKILL_DIR}` | Directory containing the SKILL.md |

**Gate:** You can write a skill from scratch that auto-invokes correctly and runs in a forked subagent.

---

## Phase 3 — Agents

Agents are isolated subagents with their own system prompt, tool list, and permissions.

```
.claude/agents/name.md
─────────────────────
name: identifier
description: When Claude should delegate here
tools: ["Read", "Grep", "Glob", "Bash"]     ← allowlist
disallowedTools: ["Write", "Edit"]          ← denylist
model: sonnet
permissionMode: default
maxTurns: 50
```

### Built-in agent types (always available)

| Type | Model | Tools | Use case |
|---|---|---|---|
| `general-purpose` | Same as main | All | Default for Agent() calls |
| `Explore` | Haiku (fast) | Read-only | Codebase searches |
| `Plan` | Same as main | Read-only | Planning mode research |

### Key rules

- Agents always run in isolation — they cannot read the main conversation context
- Skills can invoke agents via `context: fork` + `agent: type-name`
- Agents can define their own hooks in frontmatter
- `tools:` is an allowlist — if specified, only those tools are available
- `disallowedTools:` is a denylist — works alongside `tools:`

**Gate:** You can write an agent that only reads files (no writes), uses Haiku, and is invoked by a skill.

---

## Phase 4 — Hooks

Hooks are shell scripts / HTTP endpoints that fire on lifecycle events.

### Hook configuration in settings.json

```json
{
  "hooks": {
    "EventName": [
      {
        "matcher": "ToolName|OtherTool",
        "hooks": [
          { "type": "command", "command": "bash script.sh" }
        ]
      }
    ]
  }
}
```

### Critical events

| Event | When | Common use |
|---|---|---|
| `SessionStart` | Session starts or resumes | Inject context, load env |
| `UserPromptSubmit` | Before Claude processes prompt | Pre-screen input, inject context |
| `PreToolUse` | Before tool runs — **can block (exit 2)** | Validate, gate dangerous ops |
| `PostToolUse` | After tool succeeds | Auto-format, count edits |
| `PostToolUseFailure` | After tool fails | Log failures |
| `PreCompact` | Before context compaction | Export state before compression |
| `CwdChanged` | Directory changes | Reload env with direnv |

### Hook input / output

- **Input**: JSON on stdin — `session_id`, `cwd`, `hook_event_name`, tool-specific fields
- **Exit 0**: allow / no message
- **Exit 2**: block the action, print stderr to user
- **Exit other**: log only, do not block

### Hook types

| Type | Config | Use |
|---|---|---|
| `command` | `"command": "bash script.sh"` | Most common |
| `http` | `"url": "http://..."` | POST to endpoint |
| `prompt` | `"prompt": "..."` | Single-turn LLM eval |
| `agent` | `"agentType": "..."` | Multi-turn subagent check |

### Matcher syntax

```
"matcher": "Edit"              → only Edit tool
"matcher": "Edit|Write"        → Edit OR Write
"matcher": "mcp__github__.*"   → any GitHub MCP tool
```

**Gate:** You can write a hook that blocks `Bash` calls containing `rm -rf` and silently allows everything else.

---

## Phase 5 — Plugins

Plugins bundle skills + agents + hooks + MCP servers into a distributable unit.

### Plugin structure

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json          ← manifest (REQUIRED, only file here)
├── skills/
│   └── skill-name/
│       └── SKILL.md
├── agents/
│   └── agent-name.md
├── hooks/
│   └── hooks.json
└── .mcp.json                ← MCP server config (optional)
```

### plugin.json (minimal)

```json
{
  "name": "my-plugin",
  "description": "What it does",
  "version": "1.0.0",
  "author": { "name": "Your Name" }
}
```

### Key rules

- `plugin.json` lives **only** inside `.claude-plugin/` — nothing else goes there
- Plugin skills are namespaced: `/plugin-name:skill-name`
- Install via `/plugin` UI or `--plugin-dir ./path` for local testing
- Enable/disable in `settings.json` under `enabledPlugins`

### When to build a plugin vs a skill

| Situation | Use |
|---|---|
| Single reusable prompt | Skill |
| Prompt + supporting agent | Skill + Agent (no plugin needed) |
| Distributable bundle for others | Plugin |
| Needs MCP server wired in | Plugin (or `.mcp.json` in project) |
| One codebase, one team | Skills + Agents (no plugin needed) |

**Gate:** You can explain why `superpowers` and `episodic-memory` are plugins rather than skills, and what each component inside them does.

---

## Phase 6 — MCP Servers

MCP (Model Context Protocol) servers expose tools to Claude.

### Configuration

In `.mcp.json` (project-local) or `settings.json` (global):

```json
{
  "mcpServers": {
    "server-name": {
      "command": "npx",
      "args": ["-y", "@package/server"],
      "env": { "API_KEY": "${MY_API_KEY}" }
    }
  }
}
```

### Invocation in skills

Via mcporter (subprocess, no persistent state):
```bash
npx mcporter call 'server.tool(key: "value")'
```

Via autoStart (persistent, outputId survives):
```json
{ "mcpServers": { "repomix": { "autoStart": true } } }
```

**Critical**: outputId from mcporter dies when the subprocess exits. Always use `outputFilePath` returned by repomix pack operations.

### MCP servers used in this codebase

| Server | Access | Purpose |
|---|---|---|
| `repomix` | mcporter | Pack local/remote repos |
| `knowledge-graph` | mcporter | `.aim/memory.jsonl` CRUD |
| `sequential-thinking` | mcporter | Structured reasoning sessions |
| `playwright` | mcporter | Browser automation |
| `real-browser` | mcporter | Alternative browser |

**Gate:** You can call a repomix tool via mcporter, read the output file, and store findings in the knowledge graph — all from a single skill.

---

## Learning sequence (recommended order)

```
Week 1: CLAUDE.md + settings.json
        → write project CLAUDE.md from scratch
        → understand scope merging

Week 2: Commands + Skills
        → convert one workflow to a skill with proper frontmatter
        → verify auto-invocation works

Week 3: Agents
        → create a read-only reviewer agent
        → invoke it from a skill with context: fork

Week 4: Hooks
        → write a UserPromptSubmit hook that injects a file into context
        → write a PreToolUse hook that gates dangerous bash commands

Week 5: MCP + Plugins
        → call repomix via mcporter from a skill
        → read a plugin's structure and identify all its components
```

---

## What to build custom vs adopt from plugins

| Component | Build custom | Adopt from plugin |
|---|---|---|
| Project-specific workflows | Always | Never |
| Language reviewers (TS, Python, Go) | No — use plugin agents | Yes (feature-dev, code-simplifier) |
| Codebase analysis | Partially (configure codebase-analyst) | Use superpowers |
| Browser automation | No | playwright skill or e2e plugin |
| Library docs | No | context7 plugin |
| Session memory | No | episodic-memory plugin |
| CLAUDE.md management | No | claude-md-management plugin |
| Your own workflow protocols (xia, startup) | Yes — always | Never |

**Rule:** Anything that encodes how *you* think and work belongs in custom skills/commands. Anything that is a generic capability (browser, search, memory) belongs in a plugin.
