#!/bin/bash
# Install MySkills to a project (skills) and global ~/.claude (commands)

set -e

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$BASE_DIR/skills"
COMMANDS_DIR="$BASE_DIR/commands"
TARGET_PROJECT="${1:-.}"

# Install skills to project
if [ -d "$SKILLS_DIR" ] && [ "$(ls -A "$SKILLS_DIR")" ]; then
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
fi

# Install commands to global ~/.claude/commands
if [ -d "$COMMANDS_DIR" ] && [ "$(ls -A "$COMMANDS_DIR")" ]; then
  GLOBAL_COMMANDS="$HOME/.claude/commands"
  mkdir -p "$GLOBAL_COMMANDS"

  echo ""
  echo "Installing commands to $GLOBAL_COMMANDS"

  for cmd in "$COMMANDS_DIR"/*.md; do
    [ -f "$cmd" ] || continue
    cmd_name=$(basename "$cmd")
    target="$GLOBAL_COMMANDS/$cmd_name"

    if [ -L "$target" ]; then
      echo "  $cmd_name: already linked"
    elif [ -f "$target" ]; then
      echo "  $cmd_name: skipped (file exists)"
    else
      ln -s "$cmd" "$target"
      echo "  $cmd_name: linked"
    fi
  done
fi

echo ""
echo "Done!"
[ -d "$SKILLS_DIR" ] && echo "  - Add skill registrations to $TARGET_PROJECT/.claude/CLAUDE.md"
[ -d "$COMMANDS_DIR" ] && echo "  - Commands are globally available via /command-name"
