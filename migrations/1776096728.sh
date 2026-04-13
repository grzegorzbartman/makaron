#!/bin/bash
# Migration: Install Timewarrior
# Installs Timewarrior for existing users

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Install Timewarrior"
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"

if [ -f "$MAKARON_PATH/install/helpers.sh" ]; then
    # shellcheck disable=SC1090
    source "$MAKARON_PATH/install/helpers.sh"
    if [ -f "$MAKARON_PATH/install/terminal/timewarrior.sh" ]; then
        # shellcheck disable=SC1090
        source "$MAKARON_PATH/install/terminal/timewarrior.sh" || true
    else
        install_formula "timewarrior" "Timewarrior" "timew" || true
    fi
else
    echo "Helpers not found, skipping"
fi

echo "Migration completed successfully"
