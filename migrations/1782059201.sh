#!/bin/bash
# Migration: Move Ghostty config outside Makaron
# Converts the old Makaron-managed Ghostty symlink into user-owned config.

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Move Ghostty config outside Makaron"

MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"
GHOSTTY_CONFIG_DIR="$HOME/.config/ghostty"
OLD_TARGET="$MAKARON_PATH/configs/ghostty"

resolve_symlink() {
    target=$(readlink "$1")
    if [[ "$target" != /* ]]; then
        target="$(dirname "$1")/$target"
    fi
    printf '%s\n' "$target"
}

if [ -L "$GHOSTTY_CONFIG_DIR" ]; then
    resolved_target="$(resolve_symlink "$GHOSTTY_CONFIG_DIR")"
    if [ "$resolved_target" = "$OLD_TARGET" ]; then
        tmp_dir="$(mktemp -d)"

        if [ -d "$GHOSTTY_CONFIG_DIR" ]; then
            cp -R "$GHOSTTY_CONFIG_DIR/." "$tmp_dir/" 2>/dev/null || true
        fi

        rm "$GHOSTTY_CONFIG_DIR"
        mkdir -p "$GHOSTTY_CONFIG_DIR"

        if [ -d "$tmp_dir" ]; then
            cp -R "$tmp_dir/." "$GHOSTTY_CONFIG_DIR/" 2>/dev/null || true
            rm -rf "$tmp_dir"
        fi

        rm -rf "$OLD_TARGET" 2>/dev/null || true
        echo "  ✓ Converted Ghostty config symlink to user-owned directory"
    else
        echo "  ✓ Ghostty config symlink points outside Makaron, leaving it unchanged"
    fi
else
    echo "  ✓ Ghostty config is already user-managed or absent"
    rmdir "$OLD_TARGET" 2>/dev/null || true
fi

echo "Migration completed successfully"
