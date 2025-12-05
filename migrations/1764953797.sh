#!/bin/bash
# Migration: Install Bruno
# Installs Bruno API client for existing users

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Install Bruno"
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"

if [ -f "$MAKARON_PATH/install/helpers.sh" ]; then
    source "$MAKARON_PATH/install/helpers.sh"
else
    echo "Helpers not found, skipping"
    exit 0
fi

install_cask "bruno" "Bruno"

echo "Migration completed successfully"
