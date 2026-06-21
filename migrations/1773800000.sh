#!/bin/bash
# Migration: Initialize package selections for existing users
# Sets all packages as selected (existing users already have everything installed)

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Initialize package selections"
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"
PACKAGES_CONF="$HOME/.config/makaron/packages.conf"

if [ -f "$PACKAGES_CONF" ]; then
    echo "Already applied, skipping"
    exit 0
fi

mkdir -p "$(dirname "$PACKAGES_CONF")"

ALL_PACKAGES="btop ffmpeg fzf htop ncdu tmux tree fresh p10k vscode cursor sublime neovim chatgpt claude-app gemini-cli codex claude-code opencode composer ddev gh lazydocker lazygit node yarn pnpm fnm upsun bruno docker sequel-ace pipx rbenv alttab command-x stats flameshot slack spotify vlc"

cat > "$PACKAGES_CONF" << EOF
# Makaron package selections
# Re-run selection: makaron-select-packages
MAKARON_PACKAGES="$ALL_PACKAGES"
EOF

echo "Migration completed successfully"
