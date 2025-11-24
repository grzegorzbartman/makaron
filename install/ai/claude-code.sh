#!/bin/bash

# Install Claude Code
if ! brew list --cask claude-code &>/dev/null; then
    echo "Installing Claude Code..."
    brew install --cask claude-code
else
    echo "Claude Code is already installed."
fi
