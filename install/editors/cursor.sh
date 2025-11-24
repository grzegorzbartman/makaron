#!/bin/bash

# Install Cursor
if ! brew list --cask cursor &> /dev/null; then
    echo "Installing Cursor..."
    brew install --cask cursor
fi

