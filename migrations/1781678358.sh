#!/bin/bash
# Migration: Install Ice menu bar manager
#
# Ice replaces the old Dozer-style menu bar cleanup workflow for existing users.
# It remains an optional package for new installs, but existing installations get
# it automatically during makaron-update.

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Install Ice menu bar manager"

MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"
PACKAGES_CONF="${MAKARON_PACKAGES_CONF:-$HOME/.config/makaron/packages.conf}"

if [ -f "$MAKARON_PATH/install/helpers.sh" ]; then
    # shellcheck source=/dev/null
    source "$MAKARON_PATH/install/helpers.sh"
fi

if command -v brew >/dev/null 2>&1; then
    if declare -F install_cask >/dev/null 2>&1; then
        install_cask "jordanbaird-ice" "Ice" || true
    elif ! brew list --cask jordanbaird-ice >/dev/null 2>&1 && [ ! -d "/Applications/Ice.app" ]; then
        brew install --cask jordanbaird-ice || true
    else
        echo "Ice already installed"
    fi
else
    echo "  Homebrew not found, skipping Ice install"
fi

mkdir -p "$(dirname "$PACKAGES_CONF")"
if [ -f "$PACKAGES_CONF" ]; then
    # shellcheck source=/dev/null
    source "$PACKAGES_CONF"
else
    MAKARON_PACKAGES=""
fi

if [[ " ${MAKARON_PACKAGES:-} " != *" ice "* ]]; then
    updated_packages=$(echo "${MAKARON_PACKAGES:-} ice" | tr ' ' '\n' | sort -u | tr '\n' ' ' | xargs)
    cat > "$PACKAGES_CONF" << EOF
# Makaron package selections
# Re-run selection: makaron-select-packages
MAKARON_PACKAGES="$updated_packages"
EOF
    echo "  Added Ice to package selections"
fi

echo "Migration completed successfully"
