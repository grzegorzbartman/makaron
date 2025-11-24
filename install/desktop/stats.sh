#!/bin/bash

# Install Stats
if ! brew list --cask stats &> /dev/null; then
    echo "Installing Stats..."
    brew install --cask stats
fi

