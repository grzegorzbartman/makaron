#!/bin/bash

# Install Alt Tab
if ! brew list --cask alt-tab &> /dev/null; then
    echo "Installing Alt Tab..."
    brew install --cask alt-tab
fi

