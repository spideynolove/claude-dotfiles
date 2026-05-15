#!/usr/bin/env bash
# sync-history.sh push|pull
# push: commit + push all history repos before switching machines
# pull: pull latest history after arriving on a new machine
set -euo pipefail

HISTORY_DIR="$HOME/Documents/ai-history"
CODEX_MEMORIES="$HOME/.codex/memories"
ACTION="${1:-push}"

sync_repo() {
    local dir="$1" label="$2"
    [ -d "$dir/.git" ] || { echo "  $label: not a git repo, skipping"; return; }

    cd "$dir"

    if [ "$ACTION" = "push" ]; then
        git add -A
        if git diff --cached --quiet; then
            echo "  $label: nothing to commit"
        else
            git commit -m "sync: $(hostname) $(date '+%Y-%m-%d %H:%M')"
            echo "  $label: committed"
        fi
        if git remote get-url origin &>/dev/null; then
            git push
            echo "  $label: pushed"
        else
            echo "  $label: no remote configured, skipping push"
        fi
    else
        if git remote get-url origin &>/dev/null; then
            git pull --rebase
            git lfs pull 2>/dev/null || true
            echo "  $label: pulled"
        else
            echo "  $label: no remote configured, skipping pull"
        fi
    fi
}

case "$ACTION" in
push|pull)
    echo "=== sync-history: $ACTION ==="
    sync_repo "$HISTORY_DIR"    "ai-history"
    sync_repo "$CODEX_MEMORIES" "codex/memories"
    echo ""
    echo "Done. $([ "$ACTION" = "push" ] && echo 'Safe to switch machines.' || echo 'History is current.')"
    ;;
*)
    echo "Usage: $0 push|pull"
    exit 1
    ;;
esac
