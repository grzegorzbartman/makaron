#!/bin/bash
# Migration: Install aerospace-swipe (trackpad workspace switching)
# New mandatory component - existing installs won't get it from git reset alone.

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Install aerospace-swipe"
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"

if [ -f "$MAKARON_PATH/install/helpers.sh" ]; then
    source "$MAKARON_PATH/install/helpers.sh"
fi

if [ -f "$MAKARON_PATH/install/desktop/aerospace_swipe.sh" ]; then
    source "$MAKARON_PATH/install/desktop/aerospace_swipe.sh"
else
    echo "aerospace_swipe.sh not found, skipping"
fi

echo "Migration completed successfully"
