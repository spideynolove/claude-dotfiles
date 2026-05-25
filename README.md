# claude-dotfiles

Personal AI tool configuration — agents, slash commands, hooks, skills, and settings for Claude Code, Codex, OpenCode, and Gemini CLI.

## What's in here

```
.claude-global/          # Claude Code (~/.claude/)
├── CLAUDE.md            # Tool selection rules, env setup, security
├── RTK.md               # RTK token-killer usage reference
├── settings.json        # Plugins, hooks, permissions, status line
├── commands/            # Slash commands (shared with Gemini via symlink)
├── hooks/
│   ├── grep-to-rgrep.py          # Rewrites grep → rgrep on PreToolUse
│   └── context-mode-cache-heal.mjs  # Heals context-mode cache on SessionStart
└── skills/
    ├── lightpanda/      # Fast headless browser via CLI
    ├── playwright/      # Browser automation via MCP
    ├── repomix/         # Pack repos into a single context blob
    ├── sequential-thinking/  # Structured reasoning chains
    └── xia/             # Borrow patterns from GitHub repos

.agents-global/          # Subagents (~/.agents/)
├── agents/
│   ├── codebase-analyst # Builds knowledge graph from any repo
│   ├── mcp-manager      # Runs MCP tools via CLI
│   ├── orchestrator     # Full coding pipeline: clarify → analyze → plan → implement → review → test
│   └── task-runner      # Delegates tasks to external AI CLIs by role
└── skills/
    ├── code-review-graph/
    ├── interactive-learning/
    ├── next-best-practices/  # Next.js patterns
    └── rlm-workflow/

.codex-global/           # Codex CLI (~/.codex/)
├── AGENTS.md
├── config.toml
├── hooks.json
├── RTK.md
├── hooks/
│   ├── crg_session_start.py  # Injects code-review-graph context
│   ├── dedup.py              # Deduplicates history entries
│   └── rtk_codex.py          # RTK hook for Codex
└── rules/
    └── default.rules

.opencode-global/        # OpenCode (~/.opencode/)
├── AGENTS.md
├── opencode.json
├── package.json
├── commands/            # ccs, check-github-ci, commit-message, design-patterns,
│                        # e2e, explain-code, refactor, semantic-commit,
│                        # token-efficient, xia-group
└── skills/              # ccs-delegation, code-review-graph, graphify, handoff,
                         # interactive-learning, lightpanda, playwright, repomix,
                         # rlm-workflow, sequential-thinking, xia, ...

install.sh               # Copies configs to all platform dirs + installs binaries
sync-history.sh          # push/pull AI session history across machines
CROSS-PC-GUIDE.md        # Step-by-step cross-machine handoff guide
docs/                    # toolstack, tool-strategy, context-mode workflow, etc.
```

## How it works

### Installation

```bash
git clone git@github.com:spideynolove/claude-dotfiles.git ~/Documents/dotfiles/claude-dotfiles
cd ~/Documents/dotfiles/claude-dotfiles
bash install.sh
```

`install.sh` copies config files from each `*-global/` source directory into the corresponding platform config dir (`~/.claude/`, `~/.codex/`, `~/.opencode/`, `~/.gemini/`, `~/.agents/`). It also:

- Installs Python tools via `uv tool install` (`code-review-graph`)
- Registers `code-review-graph` MCP with all detected platforms
- Registers `context-mode` MCP with Claude Code
- Installs binary tools to `~/.local/bin/`: `lightpanda`, `rtk`, `tilth`
- Wires `~/.gemini/GEMINI.md` → `~/.claude/CLAUDE.md` (shared instructions)
- Clones the `ai-history` repo and symlinks session history dirs

### Plugins (Claude Code)

Enabled via `settings.json`:

| Plugin | Purpose |
|--------|---------|
| `claude-hud` | Status line in the terminal |
| `context-mode` | Context window management (MCP + skills) |
| `codex` (openai-codex) | Codex CLI integration |
| `superpowers` | Workflow skills (TDD, debugging, brainstorming, etc.) |
| `ui-ux-pro-max` | UI/UX design skill |

### Hooks (Claude Code)

| Hook | Trigger | What it does |
|------|---------|-------------|
| `rtk hook claude` | PreToolUse Bash | Rewrites shell commands for token efficiency |
| `grep-to-rgrep.py` | PreToolUse Bash | Rewrites `grep` → `rgrep` |
| `context-mode-cache-heal.mjs` | SessionStart | Heals stale context-mode cache |

### Cross-machine history sync

Session history (Claude projects, Codex sessions, Gemini history) lives in a shared `ai-history` git repo with LFS, symlinked from each platform's history dir.

Before leaving a machine:
```bash
bash sync-history.sh push
```

After arriving on a new machine:
```bash
bash install.sh && bash sync-history.sh pull
```

See `CROSS-PC-GUIDE.md` for the full step-by-step workflow.

### Orchestrated coding

```
Use the orchestrator agent for any feature request or bug fix
```

The orchestrator runs six phases:
1. **Clarify** — resolves ambiguity before touching code
2. **Analyze** — spawns `codebase-analyst` for fresh context
3. **Plan** — writes a role-annotated task list and waits for approval
4. **Implement** — spawns `task-runner` per task, delegates to the right CLI
5. **Review** — diffs the full changeset and fixes issues
6. **Test** — runs the existing test suite

### Multi-tool task routing

`task-runner` fallback chain per task:

```
preferred tool → qwen → kimi → codex → claude (inline)
```

## Key files

### `settings.json`

Shared Claude Code config: plugins, hooks, permissions (`bypassPermissions`), status line, effort level. Safe to commit. The `__NODE__` placeholder is replaced with the detected node path at install time.

### `CLAUDE.md` / `RTK.md`

Global instructions injected into every Claude Code session. `RTK.md` explains the token-saving CLI proxy. `GEMINI.md` is a symlink to `CLAUDE.md`.

### `sync-history.sh`

```bash
bash sync-history.sh push   # commit + push all history repos before switching
bash sync-history.sh pull   # pull latest history after arriving on a new machine
```

## External CLIs

| CLI | Purpose |
|-----|---------|
| `qwen` | [qwen-code](https://github.com/QwenLM/qwen-code) |
| `kimi` | [kimi-cli](https://github.com/moonshot-ai/kimi-cli) |
| `codex` | [openai/codex](https://github.com/openai/codex) |
| `gemini` | [gemini-cli](https://github.com/google-gemini/gemini-cli) |
| `rtk` | Token-killer CLI proxy — auto-installed by `install.sh` |
| `lightpanda` | Headless browser — auto-installed by `install.sh` |
| `tilth` | Status line helper — auto-installed by `install.sh` |
| `code-review-graph` | Codebase knowledge graph MCP — auto-installed by `install.sh` |

## After install

```
1. Restart Claude Code / Codex / OpenCode to pick up settings + hooks
2. Per project: cd <project> && code-review-graph build
3. Verify hooks: /context-mode:ctx-doctor in a new session
4. Verify RTK:   rtk gain
```
