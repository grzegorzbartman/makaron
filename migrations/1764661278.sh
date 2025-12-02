#!/bin/bash
# Migration: Install ncdu
# Installs ncdu (NCurses Disk Usage) for existing users

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Install ncdu"
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"

# Source helpers for install_formula function
if [ -f "$MAKARON_PATH/install/helpers.sh" ]; then
    source "$MAKARON_PATH/install/helpers.sh"
else
    echo "Helpers not found, skipping"
    exit 0
fi

# Install ncdu using helper function (handles idempotency)
install_formula "ncdu" "ncdu" "ncdu"

echo "Migration completed successfully"

