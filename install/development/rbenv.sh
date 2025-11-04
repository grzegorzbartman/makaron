#!/bin/bash

# Install rbenv
if ! command -v rbenv &> /dev/null; then
    brew install rbenv ruby-build
fi

# Initialize rbenv in shell (if not already initialized)
if ! grep -q "rbenv init" "$HOME/.zshrc" 2>/dev/null; then
    echo 'eval "$(rbenv init - zsh)"' >> "$HOME/.zshrc"
fi


