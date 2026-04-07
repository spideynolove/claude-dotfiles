#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

lns() {
    local src="$1" dst="$2"
    mkdir -p "$(dirname "$dst")"
    rm -f "$dst"
    ln -s "$src" "$dst"
}

copy_if_missing() {
    local src="$1" dst="$2"
    mkdir -p "$(dirname "$dst")"
    [ -f "$dst" ] || cp "$src" "$dst"
}

echo "=== Claude Code (~/.claude/) ==="
lns "$DOTFILES/.claude-global/CLAUDE.md" "$HOME/.claude/CLAUDE.md"

mkdir -p "$HOME/.claude/commands"
for f in "$DOTFILES/.claude-global/commands/"*.md; do
    lns "$f" "$HOME/.claude/commands/$(basename "$f")"
done

mkdir -p "$HOME/.claude/skills"
for skill_dir in "$DOTFILES/.claude-global/skills"/*/; do
    skill=$(basename "$skill_dir")
    mkdir -p "$HOME/.claude/skills/$skill"
    lns "$skill_dir/SKILL.md" "$HOME/.claude/skills/$skill/SKILL.md"
done

copy_if_missing "$DOTFILES/.claude-global/settings.json" "$HOME/.claude/settings.json"
echo "  done"

echo "=== Gemini CLI (~/.gemini/) ==="
lns "$DOTFILES/.claude-global/CLAUDE.md" "$HOME/.gemini/GEMINI.md"
lns "$DOTFILES/.gemini-global/extensions/claude-compat/gemini-extension.json" \
    "$HOME/.gemini/extensions/claude-compat/gemini-extension.json"
lns "$DOTFILES/.gemini-global/extensions/claude-compat/hooks/hooks.json" \
    "$HOME/.gemini/extensions/claude-compat/hooks/hooks.json"
copy_if_missing "$DOTFILES/.gemini-global/settings.base.json" "$HOME/.gemini/settings.json"
echo "  done"

echo "=== Qwen Code (~/.qwen/) ==="
lns "$DOTFILES/.claude-global/CLAUDE.md" "$HOME/.qwen/QWEN.md"
echo "  done"

echo "=== Codex CLI (~/.codex/) ==="
lns "$DOTFILES/.codex-global/AGENTS.md" "$HOME/.codex/AGENTS.md"
echo "  done"

echo "=== Shared agents (~/.agents/agents/) ==="
mkdir -p "$HOME/.agents/agents"
for f in "$DOTFILES/.agents-global/agents/"*.md; do
    lns "$f" "$HOME/.agents/agents/$(basename "$f")"
done
echo "  done"

echo "=== Shared skills (~/.agents/skills/) ==="
mkdir -p "$HOME/.agents/skills"
for skill_dir in "$DOTFILES/.claude-global/skills"/*/; do
    skill=$(basename "$skill_dir")
    mkdir -p "$HOME/.agents/skills/$skill"
    lns "$skill_dir/SKILL.md" "$HOME/.agents/skills/$skill/SKILL.md"
done
echo "  done"

echo ""
echo "Install complete. Cross-tool capability summary:"
echo "  Claude Code : ~/.claude/CLAUDE.md (source of truth)"
echo "  Gemini CLI  : ~/.gemini/GEMINI.md (symlink) + extensions/claude-compat (hooks)"
echo "  Qwen Code   : ~/.qwen/QWEN.md (symlink)"
echo "  Codex CLI   : ~/.codex/AGENTS.md (symlink) + ~/.agents/skills/ (skill discovery)"
echo "  Shared      : ~/.agents/agents/ (orchestrator, codebase-analyst, mcp-manager, task-runner)"
