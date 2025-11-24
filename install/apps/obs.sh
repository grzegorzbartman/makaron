#!/bin/bash

# Install OBS
if ! brew list --cask obs &> /dev/null; then
    echo "Installing OBS..."
    brew install --cask obs
fi

