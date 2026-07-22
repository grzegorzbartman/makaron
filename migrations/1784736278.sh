#!/bin/bash
# Migration: Fix aerospace-swipe CLI fallback (add Homebrew to launchd PATH)
# The launch agent runs with a minimal PATH, so the `aerospace` CLI fallback
# failed with "command not found". Re-run the installer to patch the plist.

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Fix aerospace-swipe CLI fallback PATH"
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
