#!/bin/bash

# Install GIMP
if ! brew list --cask gimp &> /dev/null; then
    echo "Installing GIMP..."
    brew install --cask gimp
fi

