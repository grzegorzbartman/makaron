#!/bin/bash

# Install Neovim
if ! command -v nvim &> /dev/null; then
    brew install neovim
fi

# Install LazyVim dependencies
if ! command -v tree-sitter &> /dev/null; then
    brew install tree-sitter-cli
fi

if ! command -v curl &> /dev/null; then
    brew install curl
fi

if ! command -v fzf &> /dev/null; then
    brew install fzf
fi

if ! command -v rg &> /dev/null; then
    brew install ripgrep
fi

if ! command -v fd &> /dev/null; then
    brew install fd
fi

# Install LazyVim
if [ ! -d "$HOME/.config/nvim" ] || [ ! -f "$HOME/.config/nvim/lua/config/lazy.lua" ]; then
    # Backup existing config if it exists
    if [ -d "$HOME/.config/nvim" ]; then
        mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak"
    fi

    # Clone LazyVim starter
    git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"

    # Remove .git folder so user can add it to their own repo later
    rm -rf "$HOME/.config/nvim/.git"
fi

