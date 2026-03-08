#!/bin/bash

install_formula "fnm" "fnm" "fnm"

if command -v fnm &>/dev/null; then
    if ! grep -q "fnm env" "$HOME/.zshrc" 2>/dev/null; then
        echo 'eval "$(fnm env --use-on-cd --shell zsh)"' >> "$HOME/.zshrc"
    fi
fi
