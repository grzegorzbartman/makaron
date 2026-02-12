#!/bin/bash

# Migration: Replace Platform.sh CLI with Upsun CLI

set -e

error_exit() {
  echo -e "\033[31mERROR: Migration failed!\033[0m" >&2
  exit 1
}

trap error_exit ERR

echo "Running migration: Replace Platform.sh CLI with Upsun CLI"

MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"

if [ -f "$MAKARON_PATH/install/helpers.sh" ]; then
    source "$MAKARON_PATH/install/helpers.sh"
fi

# Remove old platformsh-cli if installed
if brew list platformsh-cli &>/dev/null; then
    echo "Removing Platform.sh CLI..."
    brew uninstall platformsh-cli
fi

# Install Upsun CLI
if command -v upsun &>/dev/null; then
    echo "Upsun CLI already installed"
else
    echo "Installing Upsun CLI..."
    brew install platformsh/tap/upsun-cli || echo "Warning: Failed to install Upsun CLI"
fi

echo "Migration completed successfully"
