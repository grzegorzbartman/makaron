#!/bin/bash

# Install AeroSpace
install_cask "nikitabobko/tap/aerospace" "AeroSpace"

# aerospace-swipe requires AeroSpace >= 0.21 (socket protocol v1). install_cask
# skips already-installed apps, so existing users can be stuck on an older
# build where trackpad swiping silently no-ops. Upgrade in place when needed.
_aerospace_below_021() {
    local v major minor
    v="$(aerospace --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
    [ -z "$v" ] && return 1
    major="${v%%.*}"; minor="${v#*.}"; minor="${minor%%.*}"
    [ "$major" -eq 0 ] && [ "$minor" -lt 21 ]
}

if command -v aerospace &>/dev/null && _aerospace_below_021; then
    echo "Upgrading AeroSpace to >= 0.21 (required by aerospace-swipe)..."
    brew upgrade --cask nikitabobko/tap/aerospace 2>/dev/null || true
    _aerospace_below_021 && { brew reinstall --cask nikitabobko/tap/aerospace || echo "Warning: AeroSpace upgrade failed (continuing...)"; }
fi

# Setup AeroSpace config
if [ ! -L "$HOME/.aerospace.toml" ] && [ ! -f "$HOME/.aerospace.toml" ]; then
    ln -s "$MAKARON_PATH/configs/aerospace/.aerospace.toml" "$HOME/.aerospace.toml"
else
    # Check if symlink points to wrong location
    if [ -L "$HOME/.aerospace.toml" ]; then
        current_target=$(readlink "$HOME/.aerospace.toml")
        if [[ "$current_target" != "$MAKARON_PATH/configs/aerospace/.aerospace.toml" ]]; then
            echo "Fixing AeroSpace symlink to point to new location..."
            rm "$HOME/.aerospace.toml"
            ln -s "$MAKARON_PATH/configs/aerospace/.aerospace.toml" "$HOME/.aerospace.toml"
        fi
    else
        read -p "AeroSpace config exists. Overwrite? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -f "$HOME/.aerospace.toml"
            ln -s "$MAKARON_PATH/configs/aerospace/.aerospace.toml" "$HOME/.aerospace.toml"
        fi
    fi
fi
