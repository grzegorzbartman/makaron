#!/bin/bash
# Migration: Remove minimal UI mode - move existing installs to full
# The 'minimal' UI mode was removed. Installs currently in minimal are switched to full.

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Remove minimal UI mode"
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"
UI_MODE_FILE="$HOME/.local/state/makaron/ui-mode"

if [ -f "$UI_MODE_FILE" ] && grep -q '^minimal' "$UI_MODE_FILE"; then
    echo "full" > "$UI_MODE_FILE"
    echo "  ✓ ui-mode switched from minimal to full"
    if [ -f "$MAKARON_PATH/bin/makaron-ui-helpers" ]; then
        source "$MAKARON_PATH/bin/makaron-ui-helpers"
        command -v aerospace >/dev/null 2>&1 && reload_current_ui || true
    fi
else
    echo "  ✓ Not in minimal mode, nothing to do"
fi

echo "Migration completed successfully"
