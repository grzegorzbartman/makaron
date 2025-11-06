#!/bin/bash

# Install Command X
if ! brew list --cask command-x &> /dev/null; then
    echo "Installing Command X..."
    brew install --cask command-x
fi

