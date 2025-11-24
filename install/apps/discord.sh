#!/bin/bash

# Install Discord
if ! brew list --cask discord &> /dev/null; then
    echo "Installing Discord..."
    brew install --cask discord
fi

