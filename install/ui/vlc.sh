#!/bin/bash

# Install VLC
if ! brew list --cask vlc &> /dev/null; then
    echo "Installing VLC..."
    brew install --cask vlc
fi

