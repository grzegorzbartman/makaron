#!/bin/bash

# Install PHPStorm
if ! brew list --cask phpstorm &> /dev/null; then
    echo "Installing PHPStorm..."
    brew install --cask phpstorm
fi

