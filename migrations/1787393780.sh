#!/bin/bash
# Migration: Generated AeroSpace config with user overrides
# ~/.aerospace.toml now points at a generated file merged from the base
# config and ~/.config/makaron/aerospace.user.toml. Real user-owned config
# files are left untouched.

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Generated AeroSpace config"
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"
GENERATED="$HOME/.config/makaron/generated/aerospace.toml"
LINK="$HOME/.aerospace.toml"

if [ -L "$LINK" ]; then
    case "$(readlink "$LINK")" in
        "$GENERATED")
            echo "  ✓ Already pointing at the generated config"
            ;;
        *makaron*)
            bash "$MAKARON_PATH/bin/makaron-aerospace-generate"
            rm -f "$LINK"
            ln -s "$GENERATED" "$LINK"
            if [ -f "$MAKARON_PATH/bin/makaron-ui-helpers" ]; then
                source "$MAKARON_PATH/bin/makaron-ui-helpers"
                apply_desktop_state || true
            fi
            echo "  ✓ Symlink moved to the generated config"
            ;;
        *)
            echo "  ✓ Symlink is user-managed, leaving it alone"
            ;;
    esac
else
    echo "  ✓ ~/.aerospace.toml is a real user file, leaving it alone"
fi

echo "Migration completed successfully"
