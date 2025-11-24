#!/bin/bash

# Install Visual Studio Code
if ! brew list --cask visual-studio-code &> /dev/null; then
    echo "Installing Visual Studio Code..."
    brew install --cask visual-studio-code
fi

