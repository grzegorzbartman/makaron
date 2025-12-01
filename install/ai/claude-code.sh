#!/bin/bash

source "$MAKARON_PATH/install/helpers.sh"

# Check if claude binary already exists (from previous install or manual)
if command -v claude &>/dev/null; then
    echo "Claude Code already installed"
else
    install_cask "claude-code" "Claude Code"
fi
