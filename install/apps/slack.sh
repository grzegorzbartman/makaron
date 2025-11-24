#!/bin/bash

# Install Slack
if ! brew list --cask slack &> /dev/null; then
    echo "Installing Slack..."
    brew install --cask slack
fi

