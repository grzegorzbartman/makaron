#!/bin/bash

install_formula "rbenv" "rbenv" "rbenv"

# Install ruby-build if rbenv was installed
if command -v rbenv &>/dev/null; then
    install_formula "ruby-build" "ruby-build" ""
fi

# Initialize rbenv in shell (if not already initialized)
if ! grep -q "rbenv init" "$HOME/.zshrc" 2>/dev/null; then
    echo 'eval "$(rbenv init - zsh)"' >> "$HOME/.zshrc"
fi
