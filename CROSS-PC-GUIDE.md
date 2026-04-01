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

---

## Setting up on another PC

### Prerequisites
- git, bash
- Claude Code CLI installed
- Optional: qwen, kimi, codex, gemini-cli on $PATH (for multi-tool routing)

### Step 1 — Clone both repos (adjust paths as needed)

```bash
mkdir -p ~/Documents/spideynolove
git clone git@github.com:spideynolove/claude-dotfiles.git \
    ~/Documents/spideynolove/claude-dotfiles

mkdir -p ~/Public/gits
git clone git@github.com:spideynolove/claude-code-in-action.git \
    ~/Public/gits/claude-code-in-action
```

If the repos already exist at a different path, just `cd` into them and use
those paths everywhere below.

### Step 2 — Verify you are on main and up to date

```bash
cd <claude-dotfiles-path>
git checkout main
git pull origin main
git branch -a   # should show only main + remotes/origin/main

cd <claude-code-in-action-path>
git checkout main
git pull origin main
git branch -a   # same
```

### Step 3 — Backup config essentials (optional)

```bash
mkdir -p ~/.claude-backup-$(date +%Y%m%d)
for d in agents hooks skills commands memory; do
  [ -d ~/.claude/$d ] && cp -r ~/.claude/$d ~/.claude-backup-$(date +%Y%m%d)/$d
done
for f in CLAUDE.md settings.json; do
  [ -f ~/.claude/$f ] && cp ~/.claude/$f ~/.claude-backup-$(date +%Y%m%d)/$f
done
```

Do NOT `cp -r ~/.claude` — `plugins/` is 500MB+ and `projects/` is conversation history.

### Step 4 — Symlink skills into ~/.claude/skills/

`install.sh` does NOT manage `~/.claude/skills/` — do this manually first:

```bash
DOTFILES=<claude-dotfiles-path>
for skill_dir in "$DOTFILES/.claude/skills"/*/; do
  skill=$(basename "$skill_dir")
  mkdir -p ~/.claude/skills/"$skill"
  ln -sf "$skill_dir/SKILL.md" ~/.claude/skills/"$skill"/SKILL.md
done
```

### Step 5 — Run the dotfiles installer

```bash
cd <claude-dotfiles-path>
bash install.sh
```

This symlinks agents, commands, hooks, and CLAUDE.md into `~/.claude/`.

### Step 6 — Copy and edit settings.json for this machine

```bash
cp <claude-dotfiles-path>/.claude/settings.json ~/.claude/settings.json
```

Then edit `~/.claude/settings.json` for this machine:
- `statusLine.command` — update the bun path if using claude-hud
- `enabledPlugins` — disable plugins not installed on this machine
- Keep `"defaultMode": "bypassPermissions"` and `"effortLevel": "low"` as-is

Do NOT commit machine-specific settings to main.

### Step 7 — Verify ~/.claude is wired correctly

```bash
ls -la ~/.claude/agents/       # should show symlinks
ls -la ~/.claude/hooks/        # context-loader.sh + UserPromptSubmit/
ls -la ~/.claude/skills/       # skill dirs
cat ~/.claude/CLAUDE.md        # should show global instructions
```

---

## Ongoing workflow — keeping repos in sync

### Rule: never experiment directly in ~/.claude

All experimentation goes in a project-local `.claude/` directory:

```
~/my-experiment/
  .claude/
    hooks/
    commands/
    agents/
```

Claude Code merges project `.claude/` on top of `~/.claude/` automatically.

### When an experiment is validated → promote to global

1. Copy the file into `<claude-dotfiles-path>/.claude/<subdir>/`
2. Re-run `bash install.sh` to symlink it
3. Commit to `main` and push

```bash
cd <claude-dotfiles-path>
git add .claude/<subdir>/<new-file>
git commit -m "feat: add <description>"
git push origin main
```

### Pulling updates from main on another PC

```bash
cd <claude-dotfiles-path>
git pull origin main
bash install.sh          # re-run to pick up any new symlinks

cd <claude-code-in-action-path>
git pull origin main
```

---

## If another PC has leftover machine branches

```bash
cd <repo-path>
git fetch --prune          # remove stale remote-tracking refs
git branch -a              # list what still exists locally

# For each leftover branch — first check unique content:
git diff main..<branch> --name-only --diff-filter=A

# If nothing unique → delete immediately:
git branch -d <branch>

# If unique files → cherry-pick into main first:
git checkout main
git checkout <branch> -- <path/to/file>
git add <path/to/file>
git commit -m "feat: cherry-pick <file> from <branch>"
git push origin main
git branch -d <branch>
git push origin --delete <branch>   # if remote branch still exists
```

---

## File ownership map

| What | Source of truth | Never edit directly |
|------|----------------|---------------------|
| `~/.claude/CLAUDE.md` | `claude-dotfiles/.claude/CLAUDE.md` | ✓ (it's a symlink) |
| `~/.claude/agents/*.md` | `claude-dotfiles/.claude/agents/` | ✓ |
| `~/.claude/hooks/` | `claude-dotfiles/.claude/hooks/` | ✓ |
| `~/.claude/skills/*/SKILL.md` | `claude-dotfiles/.claude/skills/` | ✓ |
| `~/.claude/settings.json` | per-machine copy, not symlinked | edit freely |
| `~/.claude/projects/` | local only, never synced | — |
| `~/.claude/plugins/` | managed by Claude Code installer | — |
