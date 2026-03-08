#!/bin/bash
# Migration: Install fnm and pnpm

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Install fnm and pnpm"
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"

if [ -f "$MAKARON_PATH/install/helpers.sh" ]; then
    source "$MAKARON_PATH/install/helpers.sh"
fi

install_formula "pnpm" "pnpm" "pnpm"

if [ -f "$MAKARON_PATH/install/development/fnm.sh" ]; then
    source "$MAKARON_PATH/install/development/fnm.sh"
fi

echo "Migration completed successfully"
