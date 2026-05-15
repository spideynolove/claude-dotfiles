#!/usr/bin/env bash
# One-time setup: creates ~/Documents/ai-history, migrates history dirs, pushes to GitHub.
# Run ONCE on your primary machine. Other machines use install.sh (which clones).
set -euo pipefail

HISTORY_DIR="$HOME/Documents/ai-history"
CLAUDE_PROJECTS="$HOME/.claude/projects"
CODEX_SESSIONS="$HOME/.codex/sessions"
GEMINI_HISTORY="$HOME/.gemini/history"
GITHUB_USER="${GITHUB_USER:-spideynolove}"

# ---------------------------------------------------------------------------
echo "=== ai-history: init repo ==="

if [ -d "$HISTORY_DIR/.git" ]; then
    echo "  $HISTORY_DIR already a git repo — skipping init"
else
    mkdir -p "$HISTORY_DIR"
    git -C "$HISTORY_DIR" init
    git -C "$HISTORY_DIR" lfs install
    cat > "$HISTORY_DIR/.gitattributes" <<'EOF'
*.json  filter=lfs diff=lfs merge=lfs -text
*.jsonl filter=lfs diff=lfs merge=lfs -text
EOF
    echo "  initialized with LFS"
fi

# ---------------------------------------------------------------------------
echo "=== ai-history: migrate directories ==="

migrate_dir() {
    local src="$1" dst_name="$2"
    local dst="$HISTORY_DIR/$dst_name"

    if [ -L "$src" ]; then
        echo "  $src already a symlink — skipping"
        return
    fi

    mkdir -p "$dst"

    if [ -d "$src" ]; then
        echo "  moving $src → $dst"
        cp -a "$src/." "$dst/"
        rm -rf "$src"
    fi

    echo "  symlinking $src → $dst"
    ln -s "$dst" "$src"
}

migrate_dir "$CLAUDE_PROJECTS" "claude-projects"
migrate_dir "$CODEX_SESSIONS"  "codex-sessions"
migrate_dir "$GEMINI_HISTORY"  "gemini-history"

# ---------------------------------------------------------------------------
echo "=== ai-history: initial commit ==="

git -C "$HISTORY_DIR" add .gitattributes
for dir in claude-projects codex-sessions gemini-history; do
    [ -d "$HISTORY_DIR/$dir" ] && git -C "$HISTORY_DIR" add "$dir/" || true
done

if git -C "$HISTORY_DIR" diff --cached --quiet; then
    echo "  nothing to commit"
else
    git -C "$HISTORY_DIR" commit -m "init: migrate history from $(hostname)"
fi

# ---------------------------------------------------------------------------
echo "=== ai-history: GitHub remote ==="

if git -C "$HISTORY_DIR" remote get-url origin &>/dev/null; then
    echo "  remote 'origin' already set: $(git -C "$HISTORY_DIR" remote get-url origin)"
else
    if command -v gh &>/dev/null; then
        gh repo create ai-history --private --description "AI tool conversation history" 2>/dev/null \
            && echo "  created github.com/$GITHUB_USER/ai-history" \
            || echo "  repo may already exist on GitHub — continuing"
    else
        echo "  gh CLI not found — create the repo manually: https://github.com/new"
        echo "  then run: git -C $HISTORY_DIR remote add origin git@github.com:$GITHUB_USER/ai-history.git"
        echo "  and: git -C $HISTORY_DIR push -u origin main"
        exit 0
    fi
    git -C "$HISTORY_DIR" remote add origin "git@github.com:$GITHUB_USER/ai-history.git"
fi

echo "=== ai-history: push ==="
git -C "$HISTORY_DIR" push -u origin main

echo ""
echo "=== Setup complete ==="
echo "  History repo:  $HISTORY_DIR"
echo "  ~/.claude/projects  → $HISTORY_DIR/claude-projects"
echo "  ~/.codex/sessions   → $HISTORY_DIR/codex-sessions"
echo "  ~/.gemini/history   → $HISTORY_DIR/gemini-history"
echo ""
echo "Next: run './sync-history.sh push' before switching PCs"
echo "      run './sync-history.sh pull' after switching to a new PC"
