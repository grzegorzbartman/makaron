#!/bin/bash
# Migration: Remove Command X
# Command X is no longer managed by makaron. Remove it from package selections
# and uninstall the Homebrew cask when present.

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Remove Command X"
PKGS_CONF="$HOME/.config/makaron/packages.conf"

if [ -f "$PKGS_CONF" ]; then
    # shellcheck disable=SC1090
    source "$PKGS_CONF"
    new=$(echo "${MAKARON_PACKAGES:-}" | tr ' ' '\n' | grep -vx 'command-x' | tr '\n' ' ' | xargs)
    cat > "$PKGS_CONF" <<EOF
# Makaron package selections
# Re-run selection: makaron-select-packages
MAKARON_PACKAGES="$new"
EOF
    echo "  ✓ Removed command-x from package selections"
fi

if command -v brew >/dev/null 2>&1 && brew list --cask command-x >/dev/null 2>&1; then
    brew uninstall --cask command-x || true
    echo "  ✓ Uninstalled Command X"
else
    echo "  ✓ Command X is not installed"
fi

echo "Migration completed successfully"
