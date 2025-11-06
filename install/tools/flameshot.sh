#!/bin/bash

# Install Flameshot
if ! brew list --cask flameshot &> /dev/null; then
    echo "Installing Flameshot..."
    brew install --cask flameshot
fi

