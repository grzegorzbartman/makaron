#!/bin/bash

# Install Gemini CLI
if ! brew list gemini-cli &>/dev/null; then
    echo "Installing Gemini CLI..."
    brew install gemini-cli
else
    echo "Gemini CLI is already installed."
fi
