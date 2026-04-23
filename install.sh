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

DIR_SKILLS=(lightpanda mcp-knowledge-graph playwright repomix sequential-thinking reddit2md x2md translate-book)
FLAT_SKILLS=(debug-issue explore-codebase refactor-safely review-changes)

echo "=== Claude Code (~/.claude/) ==="

cp_file "$SRC/CLAUDE.md" "$CLAUDE/CLAUDE.md"

mkdir -p "$CLAUDE/commands"
for f in "$SRC/commands/"*.md; do
    cp_file "$f" "$CLAUDE/commands/$(basename "$f")"
done

mkdir -p "$CLAUDE/skills"
for skill in "${DIR_SKILLS[@]}"; do
    mkdir -p "$CLAUDE/skills/$skill"
    cp_file "$SRC/skills/$skill/SKILL.md" "$CLAUDE/skills/$skill/SKILL.md"
done
for skill in "${FLAT_SKILLS[@]}"; do
    cp_file "$SRC/skills/$skill.md" "$CLAUDE/skills/$skill.md"
done

[ -f "$CLAUDE/settings.json" ] || cp_file "$SRC/settings.json" "$CLAUDE/settings.json"

echo "  done"
echo ""

echo "=== MCP Servers (~/.claude.json) ==="
claude mcp add context-mode -- npx -y context-mode
claude mcp add token-savior -- "$HOME/env/.venv/bin/token-savior"
echo "  tilth: run 'tilth install claude-code --edit' after installing tilth binary"
echo "  done"
echo ""

echo "=== Binary Tools ==="

if [ ! -f "$HOME/.local/bin/lightpanda" ]; then
    echo "  installing lightpanda..."
    curl -L -o /tmp/lightpanda \
        https://github.com/lightpanda-io/browser/releases/download/nightly/lightpanda-x86_64-linux
    chmod a+x /tmp/lightpanda
    mkdir -p "$HOME/.local/bin"
    mv /tmp/lightpanda "$HOME/.local/bin/lightpanda"
    echo "  lightpanda installed"
else
    echo "  lightpanda already installed"
fi

if ! command -v tilth >/dev/null 2>&1; then
    echo "  installing tilth..."
    TILTH_VERSION=$(curl -s https://api.github.com/repos/jahala/tilth/releases/latest \
        | python3 -c "import sys,json; print(json.load(sys.stdin)['tag_name'])")
    curl -L -o /tmp/tilth \
        "https://github.com/jahala/tilth/releases/download/${TILTH_VERSION}/tilth-x86_64-unknown-linux-gnu"
    chmod a+x /tmp/tilth
    mkdir -p "$HOME/.local/bin"
    mv /tmp/tilth "$HOME/.local/bin/tilth"
    tilth install claude-code --edit
    echo "  tilth installed"
else
    echo "  tilth already installed"
fi

echo "  done"
echo ""

echo "=== Python Tools (venv: ~/env/.venv) ==="
source "$HOME/env/.venv/bin/activate" 2>/dev/null || true
uv pip install code-review-graph
uv pip install "token-savior-recall[mcp]"
code-review-graph install claude-code
echo "  done"
echo ""

echo "Install complete."
echo "  ~/.claude/CLAUDE.md"
echo "  ~/.claude/commands/ ($(ls "$CLAUDE/commands/" | wc -l) files)"
echo "  ~/.claude/skills/   (${#DIR_SKILLS[@]} dir + ${#FLAT_SKILLS[@]} flat)"
echo ""
echo "Next steps:"
echo "  1. Run 'claude mcp add tilth -- \$HOME/.local/bin/tilth --mcp --edit' if tilth was just installed"
echo "  2. Per project: cd <project> && code-review-graph build"
echo "  3. Verify: /context-mode:ctx-doctor in a new Claude Code session"
