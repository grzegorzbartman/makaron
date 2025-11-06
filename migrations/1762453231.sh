#!/bin/bash

# Migration: Install Command X
# Adds installation script for Command X tool for existing users

set -e

error_exit() {
  echo -e "\033[31mERROR: Migration failed! Manual intervention required.\033[0m" >&2
  exit 1
}

trap error_exit ERR

echo "Running migration: Install Command X"

# Set MAKARON_PATH if not already set
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"

# Install Command X
if [ -f "$MAKARON_PATH/install/ui/command-x.sh" ]; then
    echo "Installing Command X..."
    source "$MAKARON_PATH/install/ui/command-x.sh"
else
    echo "Command X installation script not found, skipping"
fi

# Individual installation scripts check if applications are already installed (idempotent)
echo "Migration completed successfully"

