#!/bin/bash
# Migration: Install cmux

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Install cmux"
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"

if [ -f "$MAKARON_PATH/install/helpers.sh" ]; then
    source "$MAKARON_PATH/install/helpers.sh"
fi

if ! brew tap | grep -q "manaflow-ai/cmux"; then
    brew tap manaflow-ai/cmux 2>/dev/null || { echo "Failed to add tap, skipping"; exit 0; }
fi

install_cask "manaflow-ai/cmux/cmux" "cmux"

echo "Migration completed successfully"
