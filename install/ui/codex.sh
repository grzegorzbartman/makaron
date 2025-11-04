#!/bin/bash

# Install Codex
if ! brew list --cask codex &> /dev/null; then
    echo "Installing Codex..."
    brew install --cask codex
fi


