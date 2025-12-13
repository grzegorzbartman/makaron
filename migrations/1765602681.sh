#!/bin/bash
# Migration: Install Sol
# Installs Sol launcher for existing users

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Install Sol"
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"

if [ -f "$MAKARON_PATH/install/helpers.sh" ]; then
    source "$MAKARON_PATH/install/helpers.sh"
else
    echo "Helpers not found, skipping"
    exit 0
fi

install_cask "sol" "Sol"

echo "Migration completed successfully"
