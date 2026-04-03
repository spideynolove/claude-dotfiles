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
rm -rf ~/.claude/plugins
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
| `.credentials.json` | Auth — never delete this |

---

### Step 3 — Run the dotfiles installer

```bash
cd ~/Documents/spideynolove/claude-dotfiles
bash install.sh
```

This symlinks agents, CLAUDE.md, and `hooks/context-loader.sh` into `~/.claude/`.
It also wires up Gemini, Qwen, and Codex configs if those tools are installed.

---

### Step 4 — Link remaining hooks and skills (install.sh gap)

`install.sh` does not wire `hooks/UserPromptSubmit/`, `hooks/PostToolUse/`, or
`skills/`. Do this manually:

```bash
DOTFILES=~/Documents/spideynolove/claude-dotfiles

# hooks/UserPromptSubmit
mkdir -p ~/.claude/hooks/UserPromptSubmit
for f in "$DOTFILES/.claude/hooks/UserPromptSubmit/"*; do
  ln -sf "$f" ~/.claude/hooks/UserPromptSubmit/$(basename "$f")
done

# hooks/PostToolUse
mkdir -p ~/.claude/hooks/PostToolUse
for f in "$DOTFILES/.claude/hooks/PostToolUse/"*; do
  ln -sf "$f" ~/.claude/hooks/PostToolUse/$(basename "$f")
done

# hooks/sync-skills-to-codex.py
ln -sf "$DOTFILES/.claude/hooks/sync-skills-to-codex.py" \
    ~/.claude/hooks/sync-skills-to-codex.py

# skills
for skill_dir in "$DOTFILES/.claude/skills"/*/; do
  skill=$(basename "$skill_dir")
  mkdir -p ~/.claude/skills/"$skill"
  ln -sf "$skill_dir/SKILL.md" ~/.claude/skills/"$skill"/SKILL.md
done
```

---

### Step 5 — Link missing commands (install.sh gap)

`install.sh` only links a subset of commands. Link the rest:

```bash
DOTFILES=~/Documents/spideynolove/claude-dotfiles
mkdir -p ~/.claude/commands
for f in "$DOTFILES/.claude/commands/"*.md; do
  ln -sf "$f" ~/.claude/commands/$(basename "$f")
done
```

---

### Step 6 — Copy settings.json for this machine

```bash
cp ~/Documents/spideynolove/claude-dotfiles/.claude/settings.json \
   ~/.claude/settings.json
```

Edit `~/.claude/settings.json` for this machine if needed:
- Remove `statusLine` block if you don't have `claude-hud` installed
- Keep `"defaultMode": "bypassPermissions"` as-is

Do NOT commit machine-specific edits back to `main`.

---

### Step 7 — Verify

```bash
echo "--- agents ---"  && ls -1 ~/.claude/agents/
echo "--- commands ---" && ls -1 ~/.claude/commands/
echo "--- hooks ---"   && ls -1 ~/.claude/hooks/
echo "--- skills ---"  && ls -1 ~/.claude/skills/
echo "--- CLAUDE.md ---" && head -3 ~/.claude/CLAUDE.md
```

Expected output: all files are symlinks pointing into `~/Documents/spideynolove/claude-dotfiles/`.

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

# Copy the file into the dotfiles repo
cp ~/my-experiment/.claude/hooks/my-hook.py \
   "$DOTFILES/.claude/hooks/my-hook.py"

# Re-run install (or manually symlink) to activate globally
ln -sf "$DOTFILES/.claude/hooks/my-hook.py" ~/.claude/hooks/my-hook.py

# Commit and push
cd "$DOTFILES"
git add .claude/hooks/my-hook.py
git commit -m "feat: add my-hook"
git push origin main
```

### Pulling updates on another PC

```bash
cd ~/Documents/spideynolove/claude-dotfiles
git pull origin main

# Re-run steps 3–5 to pick up any new files added to main
bash install.sh

DOTFILES=~/Documents/spideynolove/claude-dotfiles
for f in "$DOTFILES/.claude/commands/"*.md; do
  ln -sf "$f" ~/.claude/commands/$(basename "$f")
done
for skill_dir in "$DOTFILES/.claude/skills"/*/; do
  skill=$(basename "$skill_dir")
  mkdir -p ~/.claude/skills/"$skill"
  ln -sf "$skill_dir/SKILL.md" ~/.claude/skills/"$skill"/SKILL.md
done
```

---

## File ownership map

| What | Source of truth | Rule |
|------|----------------|------|
| `~/.claude/CLAUDE.md` | `dotfiles/.claude/CLAUDE.md` | Never edit — it's a symlink |
| `~/.claude/agents/*.md` | `dotfiles/.claude/agents/` | Never edit — symlinks |
| `~/.claude/commands/*.md` | `dotfiles/.claude/commands/` | Never edit — symlinks |
| `~/.claude/hooks/**` | `dotfiles/.claude/hooks/` | Never edit — symlinks |
| `~/.claude/skills/*/SKILL.md` | `dotfiles/.claude/skills/` | Never edit — symlinks |
| `~/.claude/settings.json` | Per-machine copy | Edit freely, don't commit |
| `~/.claude/projects/` | Local only | Never sync |
| `~/.claude/plugins/` | Claude Code managed | Never sync |
