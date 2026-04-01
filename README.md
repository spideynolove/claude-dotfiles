# claude-dotfiles

Personal Claude Code configuration — agents, slash commands, hooks, and skills that run on every project.

## What's in here

```
.claude/
├── agents/               # Subagents Claude can spawn
│   ├── codebase-analyst  # Builds knowledge graph from any repo
│   ├── mcp-manager       # Runs MCP tools via CLI or mcporter
│   ├── orchestrator      # Full coding pipeline: clarify → analyze → plan → implement → review → test
│   └── task-runner       # Delegates tasks to external AI CLIs by role
│
├── commands/             # Slash commands (/startup, /onboard, etc.)
│   ├── startup           # Single entry point: onboard → init-project → detect-roles
│   ├── onboard           # Builds .aim/memory.jsonl knowledge graph for a project
│   ├── init-project      # Generates CLAUDE.md via external CLI
│   └── detect-roles      # Detects project type, writes .aim/roles.json
│
├── hooks/
│   └── context-loader.sh # Injects knowledge graph, roles, and handoff context at session start
│
├── skills/               # Reusable prompt libraries (invoked via Skill tool)
│   ├── handoff           # Capture work state before switching machines
│   ├── mcp-knowledge-graph
│   ├── repomix
│   ├── nuxt
│   └── sequential-thinking
│
├── settings.json         # Base settings (plugins, hooks, effort level)
└── settings.home-pc.json # Machine-specific overrides (example)
```

## How it works

### Session start

`context-loader.sh` fires on every `UserPromptSubmit` hook and injects up to three context blocks into the session (each only once per session ID):

1. **Knowledge graph** — top 15 entities from `.aim/memory.jsonl` if the project has been onboarded
2. **Roles** — project type and assigned roles from `.aim/roles.json` if role detection has run
3. **Handoff** — contents of `.claude/handoff.md` if a cross-machine handoff file is present

### Project onboarding (`/startup`)

Run once per project (or after major architectural changes):

```
/startup
```

This chains three phases automatically:
1. **Onboard** — spawns `codebase-analyst` to pack the repo with repomix, analyze it with sequential-thinking, and persist entities/relations to `.aim/memory.jsonl`
2. **Init project** — uses an external AI CLI to generate `CLAUDE.md` with build commands, architecture overview, and code conventions
3. **Detect roles** — runs file-presence checks to identify the project type and proposes developer roles; writes `.aim/roles.json` on confirmation

### Orchestrated coding

```
Use the orchestrator agent for any feature request or bug fix
```

The orchestrator runs six phases:
1. **Clarify** — resolves ambiguity before touching code
2. **Analyze** — spawns `codebase-analyst` for fresh context
3. **Plan** — writes a role-annotated task list (e.g. `[backend-dev/qwen] Implement user model`) and waits for user approval
4. **Implement** — spawns `task-runner` per task, which delegates to the right CLI
5. **Review** — diffs the full changeset and fixes issues
6. **Test** — runs the existing test suite

### Multi-tool task routing

`task-runner` executes each task using the tool assigned in the plan. Fallback chain per task:

```
preferred tool → qwen → kimi → codex → claude (inline)
```

Results are written to `.aim/results/tN.json` so each task can read the previous task's output as context.

### Cross-machine handoffs (`/handoff` skill)

Before leaving a machine mid-task:

```
Use the handoff skill
```

This writes `.claude/handoff.md` with current task, next steps, open questions, and files in flight, then commits and pushes. On the next machine, `context-loader.sh` picks it up automatically at session start.

## Installation

```bash
git clone git@github.com:spideynolove/claude-dotfiles.git ~/Documents/dotfiles/claude-dotfiles
cd ~/Documents/dotfiles/claude-dotfiles
bash install.sh
```

`install.sh` symlinks each file in `.claude/` to `~/.claude/`, preserving any existing files.

For machine-specific settings, copy and rename `settings.home-pc.json`:

```bash
cp .claude/settings.home-pc.json .claude/settings.<hostname>.json
```

## Branch layout

| Branch | Machine | Notes |
|--------|---------|-------|
| `main` | — | Merged baseline, no machine-specific config |
| `home-pc` | AMD home desktop | qwen + kimi + codex installed; full multi-agent stack |
| `i5-gen12` | Intel i5 laptop | gemini-cli + kimi; handoff skill for cross-machine work |

Machine branches diverge only in `settings.<machine>.json` and any CLI-specific tool order. Core agents, commands, and skills stay in sync with `main`.

## Key files explained

### `.aim/` (per-project, gitignored)

Generated at runtime, not stored in this repo:

| File | Contents |
|------|----------|
| `memory.jsonl` | Knowledge graph — entities and relations from codebase analysis |
| `roles.json` | Detected project type and role→tool assignments |
| `plan.json` | Current task dependency graph (written by orchestrator) |
| `results/tN.json` | Per-task output from task-runner |

### `settings.json`

Shared base config: hook wiring, enabled plugins, effort level. Safe to commit.

### `settings.<machine>.json`

Machine-specific overrides. Commit to the machine branch, not main.

## External CLIs

The agents expect these tools on `$PATH` — install whichever are available on each machine:

| CLI | Install |
|-----|---------|
| `qwen` | [qwen-code](https://github.com/QwenLM/qwen-code) |
| `kimi` | [kimi-cli](https://github.com/moonshot-ai/kimi-cli) |
| `codex` | [openai/codex](https://github.com/openai/codex) |
| `gemini` | [gemini-cli](https://github.com/google-gemini/gemini-cli) |
| `npx mcporter` | bundled via npm — no install needed |
