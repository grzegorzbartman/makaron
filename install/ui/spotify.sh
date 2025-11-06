#!/bin/bash

# Install Spotify
if ! brew list --cask spotify &> /dev/null; then
    echo "Installing Spotify..."
    brew install --cask spotify
fi

