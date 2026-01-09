#!/bin/bash
# Migration: Install OpenCode
# Adds OpenCode AI coding assistant for existing users

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Install OpenCode"
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"

if command -v opencode &>/dev/null; then
    echo "OpenCode already installed, skipping"
    exit 0
fi

if [ -f "$MAKARON_PATH/install/helpers.sh" ]; then
    source "$MAKARON_PATH/install/helpers.sh"
    install_formula "anomalyco/tap/opencode" "OpenCode" "opencode"
fi

echo "Migration completed successfully"