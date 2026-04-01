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
lns "$DOTFILES/.claude/CLAUDE.md"            "$HOME/.claude/CLAUDE.md"
lns "$DOTFILES/.claude/hooks/context-loader.sh" "$HOME/.claude/hooks/context-loader.sh"
lns "$DOTFILES/.claude/agents/codebase-analyst.md"    "$HOME/.claude/agents/codebase-analyst.md"
lns "$DOTFILES/.claude/agents/mcp-manager.md"         "$HOME/.claude/agents/mcp-manager.md"
lns "$DOTFILES/.claude/agents/orchestrator.md"        "$HOME/.claude/agents/orchestrator.md"
lns "$DOTFILES/.claude/agents/task-runner.md"         "$HOME/.claude/agents/task-runner.md"
lns "$DOTFILES/.claude/agents/typescript-reviewer.md" "$HOME/.claude/agents/typescript-reviewer.md"
lns "$DOTFILES/.claude/agents/python-reviewer.md"     "$HOME/.claude/agents/python-reviewer.md"
lns "$DOTFILES/.claude/agents/go-reviewer.md"         "$HOME/.claude/agents/go-reviewer.md"
lns "$DOTFILES/.claude/agents/rust-reviewer.md"       "$HOME/.claude/agents/rust-reviewer.md"
lns "$DOTFILES/.claude/agents/refactor-cleaner.md"    "$HOME/.claude/agents/refactor-cleaner.md"
lns "$DOTFILES/.claude/agents/loop-operator.md"       "$HOME/.claude/agents/loop-operator.md"
lns "$DOTFILES/.claude/agents/e2e-runner.md"          "$HOME/.claude/agents/e2e-runner.md"
lns "$DOTFILES/.claude/commands/detect-roles.md"      "$HOME/.claude/commands/detect-roles.md"
lns "$DOTFILES/.claude/commands/init-project.md"      "$HOME/.claude/commands/init-project.md"
lns "$DOTFILES/.claude/commands/onboard.md"           "$HOME/.claude/commands/onboard.md"
lns "$DOTFILES/.claude/commands/setup-github-actions.md" "$HOME/.claude/commands/setup-github-actions.md"
lns "$DOTFILES/.claude/commands/startup.md"           "$HOME/.claude/commands/startup.md"
lns "$DOTFILES/.claude/commands/learn.md"             "$HOME/.claude/commands/learn.md"
lns "$DOTFILES/.claude/commands/e2e.md"               "$HOME/.claude/commands/e2e.md"
lns "$DOTFILES/.claude/commands/loop-start.md"        "$HOME/.claude/commands/loop-start.md"
lns "$DOTFILES/.claude/commands/loop-status.md"       "$HOME/.claude/commands/loop-status.md"
echo "  done"

echo "=== Gemini CLI (~/.gemini/) ==="
lns "$DOTFILES/.claude/CLAUDE.md" "$HOME/.gemini/GEMINI.md"
lns "$DOTFILES/.gemini/extensions/claude-compat/gemini-extension.json" \
    "$HOME/.gemini/extensions/claude-compat/gemini-extension.json"
lns "$DOTFILES/.gemini/extensions/claude-compat/hooks/hooks.json" \
    "$HOME/.gemini/extensions/claude-compat/hooks/hooks.json"
copy_if_missing "$DOTFILES/.gemini/settings.base.json" "$HOME/.gemini/settings.json"
echo "  done"

echo "=== Qwen Code (~/.qwen/) ==="
lns "$DOTFILES/.claude/CLAUDE.md" "$HOME/.qwen/QWEN.md"
echo "  done"

echo "=== Codex CLI (~/.codex/) ==="
lns "$DOTFILES/.codex/AGENTS.md" "$HOME/.codex/AGENTS.md"
echo "  done"

echo "=== Shared agents (~/.agents/agents/) ==="
mkdir -p "$HOME/.agents/agents"
for f in "$DOTFILES/.agents/agents/"*.md; do
    lns "$f" "$HOME/.agents/agents/$(basename "$f")"
done
echo "  done"

echo "=== Shared skills (~/.agents/skills/) ==="
mkdir -p "$HOME/.agents/skills"
CLAUDE_SKILLS="$HOME/.claude/skills"
for skill in sequential-thinking repomix playwright quality-tests nuxt vue-enterprise next-best-practices; do
    src="$CLAUDE_SKILLS/$skill/SKILL.md"
    if [ -f "$src" ]; then
        mkdir -p "$HOME/.agents/skills/$skill"
        lns "$src" "$HOME/.agents/skills/$skill/SKILL.md"
    fi
done
echo "  done"

echo ""
echo "Install complete. Cross-tool capability summary:"
echo "  Claude Code : ~/.claude/CLAUDE.md (source of truth)"
echo "  Gemini CLI  : ~/.gemini/GEMINI.md (symlink) + extensions/claude-compat (hooks)"
echo "  Qwen Code   : ~/.qwen/QWEN.md (symlink)"
echo "  Codex CLI   : ~/.codex/AGENTS.md (symlink) + ~/.agents/skills/ (skill discovery)"
echo "  Shared      : ~/.agents/agents/ (orchestrator, codebase-analyst, mcp-manager, task-runner)"
