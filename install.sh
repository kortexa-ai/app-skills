#!/bin/bash
# Install script for app-skills
#
# This script symlinks skills to ~/.claude/skills/ for Claude Code to discover.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$HOME/.claude/skills"

echo "Installing app-skills for Claude Code..."

# Ensure skills directory exists
mkdir -p "$SKILLS_DIR"

# List of skills to install
SKILLS=("ios-app" "osx-app" "app-logo")

for skill in "${SKILLS[@]}"; do
    SKILL_SRC="$SCRIPT_DIR/$skill"
    SKILL_DST="$SKILLS_DIR/$skill"

    if [ ! -d "$SKILL_SRC" ]; then
        echo "⚠ Skill '$skill' not found in $SCRIPT_DIR, skipping"
        continue
    fi

    if [ -L "$SKILL_DST" ]; then
        current_target=$(readlink "$SKILL_DST")
        if [ "$current_target" = "$SKILL_SRC" ]; then
            echo "✓ $skill already installed"
        else
            echo "→ Updating $skill symlink (was: $current_target)"
            rm "$SKILL_DST"
            ln -s "$SKILL_SRC" "$SKILL_DST"
            echo "✓ $skill updated"
        fi
    elif [ -d "$SKILL_DST" ]; then
        echo "⚠ $SKILL_DST exists as directory (not symlink). Skipping."
        echo "  Remove it manually if you want to link: rm -rf $SKILL_DST"
    else
        ln -s "$SKILL_SRC" "$SKILL_DST"
        echo "✓ $skill installed"
    fi
done

echo ""
echo "Installation complete!"
echo ""
echo "Available skills:"
for skill in "${SKILLS[@]}"; do
    if [ -L "$SKILLS_DIR/$skill" ] || [ -d "$SKILLS_DIR/$skill" ]; then
        desc=$(grep "^description:" "$SKILLS_DIR/$skill/SKILL.md" 2>/dev/null | sed 's/^description: //' || echo "No description")
        echo "  /$skill - $desc"
    fi
done
echo ""
echo "Use /<skill-name> in Claude Code to invoke a skill."
