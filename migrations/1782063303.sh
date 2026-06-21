#!/bin/bash
# Migration: Remove leftover MakaronBar binaries
# Stops and deletes abandoned compiled binaries from the reverted MakaronBar experiment.

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Remove leftover MakaronBar binaries"
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"

killall makaron-bar 2>/dev/null || true

for name in makaron-bar makaron-calendar-next; do
    binary="$MAKARON_PATH/bin/$name"
    if [ -e "$binary" ]; then
        rm -f "$binary"
        echo "  ✓ Removed $binary"
    else
        echo "  ✓ No $name binary present"
    fi
done

echo "Migration completed successfully"
