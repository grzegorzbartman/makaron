#!/bin/bash

# Install Steam
if ! brew list --cask steam &> /dev/null; then
    echo "Installing Steam..."
    brew install --cask steam
fi

