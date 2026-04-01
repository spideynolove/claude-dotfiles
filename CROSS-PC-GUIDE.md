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

### Step 3 — Backup config essentials (optional but recommended)

```bash
BACKUP=~/.claude-backup-$(date +%Y%m%d)
mkdir -p "$BACKUP"
for d in agents hooks skills commands memory; do
  [ -d ~/.claude/$d ] && cp -r ~/.claude/$d "$BACKUP/$d"
done
for f in CLAUDE.md settings.json; do
  [ -f ~/.claude/$f ] && cp ~/.claude/$f "$BACKUP/$f"
done
echo "Backup saved to $BACKUP (~400KB)"
```

**Do NOT** `cp -r ~/.claude` — breakdown of why:

| Dir | Size | Keep? |
|-----|------|-------|
| `plugins/` | ~550MB | No — Claude Code manages this like node_modules |
| `projects/` | ~200MB | No — conversation history, machine-local |
| `telemetry/`, `debug/` | ~50MB | No — runtime logs |
| `agents/`, `hooks/`, `skills/`, `commands/`, `settings.json` | ~400KB | **Yes** |

If `~/.claude` is fresh (never drifted), skip this step entirely and go straight to Step 4.

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

All machine branches have been deleted from remote. `main` is the only branch.
Run this on each remaining PC:

```bash
# claude-dotfiles
cd <claude-dotfiles-path>
git fetch --prune
git checkout main
git pull origin main
bash install.sh          # re-link any new files added to main

# claude-code-in-action
cd <claude-code-in-action-path>
git fetch --prune
git checkout main
git pull origin main

# Delete stale local branches (safe — -d warns if unmerged)
git branch | grep -v '^\* main' | xargs git branch -d
```

`--prune` cleans up dead remote-tracking refs for branches deleted on the
remote. `-d` is safe — it refuses to delete branches with unmerged work and
warns you instead of silently losing commits.

---

## If another PC has leftover machine branches

Since all remote branches are deleted, only local stragglers remain.

```bash
cd <repo-path>
git fetch --prune          # remove stale remote-tracking refs

# Check if a leftover branch has anything not in main:
git log main..<branch> --oneline

# Nothing unique → delete:
git branch -d <branch>

# Has unique commits → cherry-pick first, then delete:
git checkout main
git cherry-pick <commit-hash>
git push origin main
git branch -d <branch>
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
