#!/bin/bash

# Install Zulip
if ! brew list --cask zulip &> /dev/null; then
    echo "Installing Zulip..."
    brew install --cask zulip
fi

