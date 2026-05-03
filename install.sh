#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE="$HOME/.claude"
SRC="$DOTFILES/.claude-global"

cp_file() {
    local src="$1" dst="$2"
    mkdir -p "$(dirname "$dst")"
    [ -L "$dst" ] && [ ! -e "$dst" ] && rm "$dst"
    cp "$src" "$dst"
}

clean_dangling() {
    find "$1" -maxdepth 2 -type l 2>/dev/null | while read -r link; do
        [ ! -e "$link" ] && rm "$link" || true
    done
}

DIR_SKILLS=(agents-refine graphify handoff lightpanda playwright reddit2md repomix sequential-thinking x2md xia)
FLAT_SKILLS=(debug-issue explore-codebase refactor-safely review-changes)

# ---------------------------------------------------------------------------
echo "=== Claude Code (~/.claude/) ==="

clean_dangling "$CLAUDE/commands"
clean_dangling "$CLAUDE/skills"

cp_file "$SRC/CLAUDE.md"     "$CLAUDE/CLAUDE.md"
cp_file "$SRC/RTK.md"        "$CLAUDE/RTK.md"
cp_file "$SRC/settings.json" "$CLAUDE/settings.json"
NODE=$(command -v node 2>/dev/null || echo "node")
python3 - "$CLAUDE/settings.json" "$NODE" <<'PYEOF'
import sys
path, node = sys.argv[1], sys.argv[2]
with open(path) as f: content = f.read()
with open(path, "w") as f: f.write(content.replace("__NODE__", node))
PYEOF

mkdir -p "$CLAUDE/commands"
for f in "$SRC/commands/"*.md; do
    cp_file "$f" "$CLAUDE/commands/$(basename "$f")"
done

mkdir -p "$CLAUDE/hooks"
for f in "$SRC/hooks/"*.py; do
    cp_file "$f" "$CLAUDE/hooks/$(basename "$f")"
done

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
echo "=== Agents (~/.agents/) ==="

ASRC="$DOTFILES/.agents-global"
mkdir -p "$HOME/.agents/agents" "$HOME/.agents/skills"
clean_dangling "$HOME/.agents/agents"

for f in "$ASRC/agents/"*.md; do
    cp_file "$f" "$HOME/.agents/agents/$(basename "$f")"
done
cp -r "$ASRC/skills/." "$HOME/.agents/skills/"

echo "  agents: $(ls "$HOME/.agents/agents/"*.md 2>/dev/null | wc -l) files"
echo "  skills: $(ls -d "$HOME/.agents/skills/"*/ 2>/dev/null | wc -l) dirs"
echo ""

# ---------------------------------------------------------------------------
echo "=== Codex (~/.codex/) ==="

CSRC="$DOTFILES/.codex-global"
CODEX="$HOME/.codex"
clean_dangling "$CODEX"

cp_file "$CSRC/AGENTS.md"   "$CODEX/AGENTS.md"
cp_file "$CSRC/config.toml" "$CODEX/config.toml"
cp_file "$CSRC/hooks.json"  "$CODEX/hooks.json"
cp_file "$CSRC/RTK.md"      "$CODEX/RTK.md"

mkdir -p "$CODEX/hooks"
for f in "$CSRC/hooks/"*.py; do
    cp_file "$f" "$CODEX/hooks/$(basename "$f")"
done

mkdir -p "$CODEX/rules"
for f in "$CSRC/rules/"*; do
    cp_file "$f" "$CODEX/rules/$(basename "$f")"
done

echo "  AGENTS.md, config.toml, hooks.json, RTK.md"
echo "  hooks: $(ls "$CODEX/hooks/"*.py 2>/dev/null | wc -l) files"
echo ""

# ---------------------------------------------------------------------------
echo "=== OpenCode (~/.opencode/) ==="

OSRC="$DOTFILES/.opencode-global"
OPENCODE="$HOME/.opencode"

cp_file "$OSRC/AGENTS.md"     "$OPENCODE/AGENTS.md"
cp_file "$OSRC/opencode.json" "$OPENCODE/opencode.json"
cp_file "$OSRC/package.json"  "$OPENCODE/package.json"

mkdir -p "$OPENCODE/commands"
for f in "$OSRC/commands/"*; do
    cp_file "$f" "$OPENCODE/commands/$(basename "$f")"
done

mkdir -p "$OPENCODE/skills"
cp -r "$OSRC/skills/." "$OPENCODE/skills/"

echo "  AGENTS.md, opencode.json, package.json"
echo "  commands: $(ls "$OPENCODE/commands/" | wc -l) files"
echo "  skills:   $(ls -d "$OPENCODE/skills/"*/ 2>/dev/null | wc -l) dirs"
echo ""

# ---------------------------------------------------------------------------
echo "=== Gemini (~/.gemini/) ==="

GEMINI="$HOME/.gemini"
mkdir -p "$GEMINI"

# GEMINI.md — symlink to ~/.claude/CLAUDE.md (single source of truth)
[ -L "$GEMINI/GEMINI.md" ] && rm "$GEMINI/GEMINI.md"
[ -f "$GEMINI/GEMINI.md" ] && mv "$GEMINI/GEMINI.md" "$GEMINI/GEMINI.md.bak"
ln -s "$CLAUDE/CLAUDE.md" "$GEMINI/GEMINI.md"
echo "  GEMINI.md → ~/.claude/CLAUDE.md"

# commands — symlink to ~/.claude/commands (shared slash commands)
[ -L "$GEMINI/commands" ] && rm "$GEMINI/commands"
ln -s "$CLAUDE/commands" "$GEMINI/commands"
echo "  commands/ → ~/.claude/commands/"

# MCP: code-review-graph (gemini not a CRG-supported platform — wire manually)
python3 - <<'PYEOF'
import json, os
path = os.path.expanduser("~/.gemini/settings.json")
try:
    with open(path) as f:
        cfg = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    cfg = {}
cfg.setdefault("mcpServers", {})
cfg["mcpServers"]["code-review-graph"] = {"command": "code-review-graph", "args": ["serve"]}
with open(path, "w") as f:
    json.dump(cfg, f, indent=2)
print("  code-review-graph MCP → ~/.gemini/settings.json")
PYEOF

echo ""

# ---------------------------------------------------------------------------
echo "=== Python Tools ==="

# code-review-graph: uv tool install → ~/.local/bin/ (on PATH, no venv activation needed)
# hooks call ["code-review-graph", ...] as subprocess — must be on PATH
uv tool install --reinstall code-review-graph
echo "  code-review-graph: $(code-review-graph --version)"

# token-savior: stays in venv — MCP config uses full venv path intentionally
source "$HOME/env/.venv/bin/activate" 2>/dev/null || { echo "  warn: venv not found at ~/env/.venv"; }
uv pip install "token-savior-recall[mcp]"
echo "  token-savior: $("$HOME/env/.venv/bin/token-savior" --version 2>/dev/null || echo installed)"

# Register CRG with all detected platforms (claude-code, codex, opencode, ...)
# gemini excluded — handled above via settings.json
code-review-graph install -y --platform all
echo "  CRG registered for all detected platforms"
echo ""

# ---------------------------------------------------------------------------
echo "=== MCP Servers (Claude Code) ==="
claude mcp add -s user context-mode -- npx -y context-mode 2>/dev/null && echo "  context-mode registered" || echo "  context-mode already registered"
claude mcp add -s user token-savior -- "$HOME/env/.venv/bin/token-savior" 2>/dev/null && echo "  token-savior registered" || echo "  token-savior already registered"
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
echo "  1. Restart Claude Code / Codex / OpenCode to pick up settings + hooks"
echo "  2. Per project: cd <project> && code-review-graph build"
echo "  3. Verify hooks: /context-mode:ctx-doctor in a new session"
echo "  4. Verify RTK:   rtk gain"
echo "  5. Sync to LAN:  rsync -av --exclude='projects/' --exclude='file-history/' \\"
echo "       --exclude='context-mode/' --exclude='backups/' --exclude='paste-cache/' \\"
echo "       --exclude='.credentials.json' ~/.claude/ hung@192.168.100.122:~/.claude/"
