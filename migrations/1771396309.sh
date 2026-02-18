#!/bin/bash
# Migration: Install Fresh Editor

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Install Fresh Editor"
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"

if [ -f "$MAKARON_PATH/install/helpers.sh" ]; then
    source "$MAKARON_PATH/install/helpers.sh"
fi

if ! brew tap | grep -q "sinelaw/fresh"; then
    brew tap sinelaw/fresh 2>/dev/null || { echo "Failed to add tap, skipping"; exit 0; }
fi

install_formula "fresh-editor" "Fresh Editor" "fresh"

echo "Migration completed successfully"
