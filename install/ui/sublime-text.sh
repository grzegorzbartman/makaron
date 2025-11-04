#!/bin/bash

# Install Sublime Text
if ! brew list --cask sublime-text &> /dev/null; then
    echo "Installing Sublime Text..."
    brew install --cask sublime-text
fi


