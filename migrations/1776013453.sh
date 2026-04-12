#!/bin/bash
# Migration: Install Todoist CLI
# Installs @doist/todoist-cli for existing users

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Install Todoist CLI"
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"

if [ -f "$MAKARON_PATH/install/helpers.sh" ]; then
    # shellcheck disable=SC1090
    source "$MAKARON_PATH/install/helpers.sh"
    install_npm_global_package "@doist/todoist-cli" "Todoist CLI" || true
else
    echo "Helpers not found, skipping"
fi

echo "Migration completed successfully"
