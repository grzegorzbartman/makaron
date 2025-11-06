#!/bin/bash

# Install Inkscape
if ! brew list --cask inkscape &> /dev/null; then
    echo "Installing Inkscape..."
    brew install --cask inkscape
fi

