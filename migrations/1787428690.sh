#!/bin/bash
# Migration: Compile shortcut overlay panel
# Existing installs compile bin/makaron-help-window (new installs get it via
# install/desktop/sketchybar.sh). Without it makaron-help opens the generated
# HTML in the default browser instead of the glass panel.

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Compile shortcut overlay panel"
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"

if [ -x "$MAKARON_PATH/bin/makaron-help-window" ]; then
    echo "  ✓ Already compiled"
elif command -v swiftc >/dev/null 2>&1 && [ -f "$MAKARON_PATH/src/help_window.swift" ]; then
    swiftc -O -o "$MAKARON_PATH/bin/makaron-help-window" "$MAKARON_PATH/src/help_window.swift" 2>/dev/null \
        && echo "  ✓ Compiled makaron-help-window" \
        || echo "  ⚠️  Compile failed, makaron-help will open in the browser"
else
    echo "  ⚠️  swiftc not available, makaron-help will open in the browser"
fi

echo "Migration completed successfully"
