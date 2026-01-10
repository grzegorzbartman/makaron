#!/bin/bash
# Migration: Install OpenCode Desktop
# Installs OpenCode Desktop GUI app for existing users

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Install OpenCode Desktop"
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"

if [ -f "$MAKARON_PATH/install/helpers.sh" ]; then
    source "$MAKARON_PATH/install/helpers.sh"
    install_cask "opencode-desktop" "OpenCode"
fi

echo "Migration completed successfully"
