#!/bin/bash

# Install Neovim
install_formula "neovim" "Neovim" "nvim"

# Install LazyVim dependencies
install_formula "tree-sitter-cli" "tree-sitter" "tree-sitter"
install_formula "curl" "curl" "curl"
install_formula "fzf" "fzf" "fzf"
install_formula "ripgrep" "ripgrep" "rg"
install_formula "fd" "fd" "fd"

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

