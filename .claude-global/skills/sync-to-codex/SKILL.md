---
name: sync-to-codex
description: Sync Claude Code skills to Codex CLI and Qwen Code via filesystem symlinks. One source of truth at ~/.claude/skills/, symlinked into ~/.codex/skills/ and ~/.qwen/skills/. Respects targets: frontmatter field.
argument-hint: "[--dry-run]"
targets: [claude]
---

# sync-to-codex

Syncs skills from `~/.claude/skills/` → `~/.codex/skills/` and `~/.qwen/skills/` using symlinks.

Both tools read plain markdown SKILL.md files from their own paths. No translation — the format is identical across Claude Code, Codex CLI, and Qwen Code.

```
~/.claude/skills/my-skill/SKILL.md   ← one source
         ↓ symlink
~/.codex/skills/my-skill/            ← Codex CLI reads this
~/.qwen/skills/my-skill/             ← Qwen Code reads this
```

The PostToolUse hook fires automatically after any Edit or Write to a `.claude/skills/` file.

## Manual sync

```bash
python3 ~/.claude/hooks/sync-skills-to-codex.py
```

Dry-run (preview, no filesystem changes):

```bash
python3 ~/.claude/hooks/sync-skills-to-codex.py --dry-run
```

## Filtering with targets: frontmatter

```yaml
---
targets: [claude, codex, qwen]   # all three
---
```

```yaml
---
targets: [claude]                 # Claude Code only
---
```

Omitting `targets:` syncs to all tools by default.

## Env overrides

```bash
SKILLSHARE_SOURCE=~/.claude/skills \
SKILLSHARE_CODEX_TARGET=~/.codex/skills \
python3 ~/.claude/hooks/sync-skills-to-codex.py
```

## Manifest

`~/.codex/skills/.skillshare-manifest.json` and `~/.qwen/skills/.skillshare-manifest.json` track managed symlinks. The prune step only removes symlinks it created — manually placed files are never touched.
