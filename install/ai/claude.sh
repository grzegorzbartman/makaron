#!/bin/bash

# Install Claude Desktop App
if ! brew list --cask claude &>/dev/null; then
    echo "Installing Claude..."
    brew install --cask claude
else
    echo "Claude is already installed."
fi
