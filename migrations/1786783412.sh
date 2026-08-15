#!/bin/bash
# Migration: Install Themes v2 window borders
# Adds the new user preferences and installs JankyBorders for existing users.

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Install Themes v2 window borders"
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"

if [ -f "$MAKARON_PATH/install/desktop/borders.sh" ]; then
    source "$MAKARON_PATH/install/desktop/borders.sh"
fi

if [ -f "$MAKARON_PATH/install/makaron-conf.sh" ]; then
    source "$MAKARON_PATH/install/makaron-conf.sh"
fi

echo "Migration completed successfully"
