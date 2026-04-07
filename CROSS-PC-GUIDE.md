# Cross-PC Setup & Sync Guide

## What was done (home-pc, 2026-04-01)

Both repos were consolidated to a single `main` branch. All machine branches
(`home-pc`, `hung-h81`, `i5-gen12`, `home-refresh`) were deleted after their
unique content was cherry-picked into `main`.

### claude-dotfiles — what was merged into main
- `install.sh` rewritten (robust symlink helper, cross-tool: Gemini/Qwen/Codex)
- `README.md` significantly expanded with how-it-works docs
- `test-classifier.sh` added to hooks/UserPromptSubmit/

### claude-code-in-action — what was merged into main
- `home-pc`: modules 24-token-efficiency, role agents/commands, xia patterns
- `hung-h81`: modules 25–35, reviewer agents, codegraphcontext/repomix skills
- `i5-gen12`: real-browser-mcp guide, browser-mcp CLAUDE.md, agents-setup.md
- `home-refresh`: dotfiles subagents, orchestrator/mcp-manager docs

## What was done (hung-h81, 2026-04-02)

Remaining machine branches (`hung-h81`, `home-pc`, `i5-gen12`) merged into
`main` and deleted from remote. All branches are now gone — `main` is the only
branch.

### claude-code-in-action — what was merged into main
- `hung-h81` (21 commits): modules 20-35, skill libraries, xia pattern set,
  reviewer agents, codegraphcontext/repomix skills, 20-skill-sync hook
- `home-pc` (1 commit): token-efficiency skill, role system agents/commands,
  05-subagents restructure (agents-setup.md → SYSTEM.md)
- `i5-gen12` (1 commit): browser MCP migration to dev-browser, real-browser-mcp
  guide

## What was done (home-pc, 2026-04-07)

Dotfiles folders renamed with `-global` suffix to prevent Claude Code and other
tools from auto-loading them as project-local config when working inside the
dotfiles repo itself.

- `.claude/` → `.claude-global/`
- `.agents/` → `.agents-global/`
- `.codex/` → `.codex-global/`
- `.gemini/` → `.gemini-global/`

`install.sh` updated to reflect new paths. Agents removed from `~/.claude/agents/`
(agents live only in `~/.agents/agents/`). Hooks removed from dotfiles source;
hooks in `~/.claude/hooks/` are machine-local only.

---

## Fresh setup / refresh on any PC

Use this when setting up for the first time **or** when your `~/.claude` has
drifted from the canonical dotfiles (experimental hooks, stale agents, etc.).

### Prerequisites

- git, bash
- Claude Code CLI installed (`claude --version` should work)
- SSH key added to GitHub (for `git@github.com:` clones)
- Optional: qwen, codex, gemini-cli on `$PATH` (for multi-tool routing)

---

### Step 1 — Get the latest dotfiles

**First time on this machine:**
```bash
mkdir -p ~/Documents/spideynolove
git clone git@github.com:spideynolove/claude-dotfiles.git \
    ~/Documents/spideynolove/claude-dotfiles
```

**Already cloned — just pull:**
```bash
cd ~/Documents/spideynolove/claude-dotfiles
git checkout main && git pull origin main
```

Also pull `claude-code-in-action` if you use it for learning:
```bash
mkdir -p ~/Public/gits
git clone git@github.com:spideynolove/claude-code-in-action.git \
    ~/Public/gits/claude-code-in-action
# or: cd ~/Public/gits/claude-code-in-action && git pull origin main
```

---

### Step 2 — Wipe drifted config from `~/.claude`

This removes everything you manually added or experimented with.
Claude Code runtime data (history, cache, sessions) is left untouched.

```bash
rm -rf ~/.claude/agents
rm -rf ~/.claude/commands
rm -rf ~/.claude/hooks
rm -rf ~/.claude/skills
rm -f  ~/.claude/CLAUDE.md
rm -f  ~/.claude/settings.json
rm -f  ~/.claude/settings.json.backup-*
rm -f  ~/.claude/settings.json.*-backup-*
rm -f  ~/.claude/hooks.json
rm -rf ~/.claude/XIALOGUE.md
```

What NOT to delete — these are all auto-managed by Claude Code:

| Dir / File | What it is |
|------------|-----------|
| `cache/`, `debug/`, `downloads/` | Runtime caches |
| `file-history/`, `history.jsonl` | Conversation history |
| `projects/`, `sessions/`, `session-env/` | Per-project state |
| `todos/`, `shell-snapshots/`, `paste-cache/` | Session data |
| `statsig/`, `telemetry/`, `stats-cache.json` | Telemetry |
| `plugins/` | Claude Code managed — never delete |
| `.credentials.json` | Auth — never delete this |

---

### Step 3 — Run the dotfiles installer

```bash
cd ~/Documents/spideynolove/claude-dotfiles
bash install.sh
```

This symlinks CLAUDE.md, all commands, and all skills into `~/.claude/`.
It also wires up Gemini, Qwen, and Codex configs if those tools are installed.
Shared agents go into `~/.agents/agents/`.

---

### Step 4 — Copy settings.json for this machine

```bash
cp ~/Documents/spideynolove/claude-dotfiles/.claude-global/settings.json \
   ~/.claude/settings.json
```

Edit `~/.claude/settings.json` for this machine if needed:
- Remove `statusLine` block if you don't have `claude-hud` installed
- Keep `"defaultMode": "bypassPermissions"` as-is

Do NOT commit machine-specific edits back to `main`.

---

### Step 5 — Verify

```bash
echo "--- commands ---" && ls -1 ~/.claude/commands/
echo "--- skills ---"  && ls -1 ~/.claude/skills/
echo "--- agents ---"  && ls -1 ~/.agents/agents/
echo "--- CLAUDE.md ---" && head -3 ~/.claude/CLAUDE.md
```

Expected output: CLAUDE.md and commands/skills are symlinks pointing into
`~/Documents/spideynolove/claude-dotfiles/.claude-global/`.

---

## Ongoing workflow — keeping repos in sync

### Golden rule: never experiment directly in `~/.claude`

All experimentation goes in a **project-local** `.claude/` directory:

```
~/my-experiment/
  .claude/
    hooks/
    commands/
    agents/
```

Claude Code merges project `.claude/` on top of `~/.claude/` automatically.
Experiment there → validate → then promote to global.

### Promoting a validated experiment to global

```bash
DOTFILES=~/Documents/spideynolove/claude-dotfiles

# Copy the file into the dotfiles repo (under .claude-global/)
cp ~/my-experiment/.claude/commands/my-command.md \
   "$DOTFILES/.claude-global/commands/my-command.md"

# Re-run install to activate globally
bash "$DOTFILES/install.sh"

# Commit and push
cd "$DOTFILES"
git add .claude-global/commands/my-command.md
git commit -m "feat: add my-command"
git push origin main
```

### Pulling updates on another PC

```bash
cd ~/Documents/spideynolove/claude-dotfiles
git pull origin main

# Re-run install to pick up any new files added to main
bash install.sh
```

---

## File ownership map

| What | Source of truth | Rule |
|------|----------------|------|
| `~/.claude/CLAUDE.md` | `dotfiles/.claude-global/CLAUDE.md` | Never edit — it's a symlink |
| `~/.claude/commands/*.md` | `dotfiles/.claude-global/commands/` | Never edit — symlinks |
| `~/.claude/skills/*/SKILL.md` | `dotfiles/.claude-global/skills/` | Never edit — symlinks |
| `~/.agents/agents/*.md` | `dotfiles/.agents-global/agents/` | Never edit — symlinks |
| `~/.claude/hooks/**` | Machine-local only | Edit freely, don't commit |
| `~/.claude/settings.json` | Per-machine copy | Edit freely, don't commit |
| `~/.claude/projects/` | Local only | Never sync |
| `~/.claude/plugins/` | Claude Code managed | Never sync, never delete |
