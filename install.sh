#!/bin/bash
# Symlink ~/.claude portable files from this dotfiles repo
# Run once on each new machine after cloning

REPO_DIR="$(cd "$(dirname "$0")" && pwd)/.claude"
TARGET="$HOME/.claude"

mkdir -p "$TARGET/agents" "$TARGET/hooks" "$TARGET/skills"

for f in "$REPO_DIR/agents/"*.md; do
  ln -sf "$f" "$TARGET/agents/$(basename "$f")"
  echo "linked agents/$(basename "$f")"
done

for skill_dir in "$REPO_DIR/skills/"*/; do
  skill_name=$(basename "$skill_dir")
  mkdir -p "$TARGET/skills/$skill_name"
  ln -sf "$skill_dir/SKILL.md" "$TARGET/skills/$skill_name/SKILL.md"
  echo "linked skills/$skill_name/SKILL.md"
done

for f in "$REPO_DIR/hooks/"*; do
  ln -sf "$f" "$TARGET/hooks/$(basename "$f")"
  chmod +x "$f"
  echo "linked hooks/$(basename "$f")"
done

ln -sf "$REPO_DIR/CLAUDE.md" "$TARGET/CLAUDE.md"
echo "linked CLAUDE.md"

echo ""
echo "Done. Copy and edit settings.json manually:"
echo "  cp $REPO_DIR/settings.json $TARGET/settings.json"
echo "  Update node/python paths for this machine."
