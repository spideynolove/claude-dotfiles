#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE="$HOME/.claude"
SRC="$DOTFILES/.claude-global"

cp_file() {
    local src="$1" dst="$2"
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
}

SKILLS=(lightpanda mcp-knowledge-graph playwright repomix sequential-thinking)

echo "=== Claude Code (~/.claude/) ==="

cp_file "$SRC/CLAUDE.md" "$CLAUDE/CLAUDE.md"

mkdir -p "$CLAUDE/commands"
for f in "$SRC/commands/"*.md; do
    cp_file "$f" "$CLAUDE/commands/$(basename "$f")"
done

mkdir -p "$CLAUDE/skills"
for skill in "${SKILLS[@]}"; do
    mkdir -p "$CLAUDE/skills/$skill"
    cp_file "$SRC/skills/$skill/SKILL.md" "$CLAUDE/skills/$skill/SKILL.md"
done

[ -f "$CLAUDE/settings.json" ] || cp_file "$SRC/settings.json" "$CLAUDE/settings.json"

echo "  done"
echo ""
echo "Install complete."
echo "  ~/.claude/CLAUDE.md"
echo "  ~/.claude/commands/ ($(ls "$CLAUDE/commands/" | wc -l) files)"
echo "  ~/.claude/skills/   (${#SKILLS[@]} skills: ${SKILLS[*]})"
