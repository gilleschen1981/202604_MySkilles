#!/bin/bash
# Install MySkills to a project

set -e

SKILLS_DIR="$(cd "$(dirname "$0")" && pwd)/skills"
TARGET_PROJECT="${1:-.}"

if [ ! -d "$TARGET_PROJECT" ]; then
  echo "Error: $TARGET_PROJECT is not a directory"
  exit 1
fi

TARGET_SKILLS="$TARGET_PROJECT/.claude/skills"
mkdir -p "$TARGET_SKILLS"

echo "Installing skills to $TARGET_SKILLS"

for skill in "$SKILLS_DIR"/*/; do
  skill_name=$(basename "$skill")
  target="$TARGET_SKILLS/$skill_name"

  if [ -L "$target" ]; then
    echo "  $skill_name: already linked"
  elif [ -d "$target" ]; then
    echo "  $skill_name: skipped (directory exists)"
  else
    ln -s "$skill" "$target"
    echo "  $skill_name: linked"
  fi
done

echo ""
echo "Done! Add skill registrations to $TARGET_PROJECT/.claude/CLAUDE.md"
