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

DIR_SKILLS=(agents-refine graphify handoff lightpanda playwright reddit2md repomix sequential-thinking x2md xia)
FLAT_SKILLS=(debug-issue explore-codebase refactor-safely review-changes)

# ---------------------------------------------------------------------------
echo "=== Claude Code (~/.claude/) ==="

cp_file "$SRC/CLAUDE.md"  "$CLAUDE/CLAUDE.md"
cp_file "$SRC/RTK.md"     "$CLAUDE/RTK.md"

# settings.json — always overwrite so token-saving changes propagate
cp_file "$SRC/settings.json" "$CLAUDE/settings.json"

# commands
mkdir -p "$CLAUDE/commands"
for f in "$SRC/commands/"*.md; do
    cp_file "$f" "$CLAUDE/commands/$(basename "$f")"
done

# hooks
mkdir -p "$CLAUDE/hooks"
for f in "$SRC/hooks/"*.py; do
    cp_file "$f" "$CLAUDE/hooks/$(basename "$f")"
done

# skills
mkdir -p "$CLAUDE/skills"
for skill in "${DIR_SKILLS[@]}"; do
    mkdir -p "$CLAUDE/skills/$skill"
    cp_file "$SRC/skills/$skill/SKILL.md" "$CLAUDE/skills/$skill/SKILL.md"
done
for skill in "${FLAT_SKILLS[@]}"; do
    [ -f "$SRC/skills/$skill.md" ] && cp_file "$SRC/skills/$skill.md" "$CLAUDE/skills/$skill.md"
done

echo "  CLAUDE.md, RTK.md, settings.json"
echo "  commands: $(ls "$CLAUDE/commands/" | wc -l) files"
echo "  hooks:    $(ls "$CLAUDE/hooks/" | wc -l) files"
echo "  skills:   ${#DIR_SKILLS[@]} dir + ${#FLAT_SKILLS[@]} flat"
echo ""

# ---------------------------------------------------------------------------
echo "=== Python Tools (venv: ~/env/.venv) ==="
source "$HOME/env/.venv/bin/activate" 2>/dev/null || { echo "  warn: venv not found at ~/env/.venv"; }
uv pip install code-review-graph
uv pip install "token-savior-recall[mcp]"
code-review-graph install claude-code
echo "  done"
echo ""

# ---------------------------------------------------------------------------
echo "=== MCP Servers ==="
claude mcp add context-mode -- npx -y context-mode 2>/dev/null && echo "  context-mode registered" || echo "  context-mode already registered"
claude mcp add token-savior -- "$HOME/env/.venv/bin/token-savior" 2>/dev/null && echo "  token-savior registered" || echo "  token-savior already registered"
echo ""

# ---------------------------------------------------------------------------
echo "=== Binary Tools ==="

if [ ! -f "$HOME/.local/bin/lightpanda" ]; then
    echo "  installing lightpanda..."
    curl -fsSL -o /tmp/lightpanda \
        https://github.com/lightpanda-io/browser/releases/download/nightly/lightpanda-x86_64-linux
    chmod +x /tmp/lightpanda
    mkdir -p "$HOME/.local/bin"
    mv /tmp/lightpanda "$HOME/.local/bin/lightpanda"
    echo "  lightpanda installed"
else
    echo "  lightpanda already installed"
fi

if ! command -v rtk >/dev/null 2>&1; then
    echo "  installing rtk..."
    RTK_VERSION=$(curl -fsSL https://api.github.com/repos/rtk-ai/rtk/releases/latest \
        | python3 -c "import sys,json; print(json.load(sys.stdin)['tag_name'])")
    curl -fsSL -o /tmp/rtk \
        "https://github.com/rtk-ai/rtk/releases/download/${RTK_VERSION}/rtk-x86_64-unknown-linux-gnu"
    chmod +x /tmp/rtk
    mkdir -p "$HOME/.local/bin"
    mv /tmp/rtk "$HOME/.local/bin/rtk"
    rtk init -g
    echo "  rtk installed — run: rtk --version && rtk gain"
else
    echo "  rtk already installed"
fi

if ! command -v tilth >/dev/null 2>&1; then
    echo "  installing tilth..."
    TILTH_VERSION=$(curl -fsSL https://api.github.com/repos/jahala/tilth/releases/latest \
        | python3 -c "import sys,json; print(json.load(sys.stdin)['tag_name'])")
    curl -fsSL -o /tmp/tilth \
        "https://github.com/jahala/tilth/releases/download/${TILTH_VERSION}/tilth-x86_64-unknown-linux-gnu"
    chmod +x /tmp/tilth
    mkdir -p "$HOME/.local/bin"
    mv /tmp/tilth "$HOME/.local/bin/tilth"
    tilth install claude-code --edit
    echo "  tilth installed"
else
    echo "  tilth already installed"
fi

echo "  done"
echo ""

# ---------------------------------------------------------------------------
echo "=== Install complete ==="
echo ""
echo "Next steps:"
echo "  1. Restart Claude Code to pick up settings.json + hooks"
echo "  2. Per project: cd <project> && code-review-graph build"
echo "  3. Verify hooks: /context-mode:ctx-doctor in a new session"
echo "  4. Verify RTK:   rtk gain"
echo "  5. Sync to LAN:  rsync -av --exclude='projects/' --exclude='file-history/' \\"
echo "       --exclude='context-mode/' --exclude='backups/' --exclude='paste-cache/' \\"
echo "       --exclude='.credentials.json' ~/.claude/ hung@192.168.100.122:~/.claude/"
