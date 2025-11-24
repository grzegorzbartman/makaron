#!/bin/bash

# Install ChatGPT
if ! brew list --cask chatgpt &> /dev/null; then
    echo "Installing ChatGPT..."
    brew install --cask chatgpt
fi


