#!/bin/bash

# Migration: Install lazygit and lazydocker
# Adds installation scripts for lazygit and lazydocker development tools for existing users

set -e

error_exit() {
  echo -e "\033[31mERROR: Migration failed! Manual intervention required.\033[0m" >&2
  exit 1
}

trap error_exit ERR

echo "Running migration: Install lazygit and lazydocker"

# Set MAKARON_PATH if not already set
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"

# Install lazygit
if [ -f "$MAKARON_PATH/install/development/lazygit.sh" ]; then
    echo "Installing lazygit..."
    source "$MAKARON_PATH/install/development/lazygit.sh"
else
    echo "lazygit installation script not found, skipping"
fi

# Install lazydocker
if [ -f "$MAKARON_PATH/install/development/lazydocker.sh" ]; then
    echo "Installing lazydocker..."
    source "$MAKARON_PATH/install/development/lazydocker.sh"
else
    echo "lazydocker installation script not found, skipping"
fi

# Individual installation scripts check if applications are already installed (idempotent)
echo "Migration completed successfully"

