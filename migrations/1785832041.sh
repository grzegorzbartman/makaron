#!/bin/bash
# Migration: Install Upsun CLI from its current Homebrew tap
# The previous platformsh/tap/upsun-cli formula was removed.

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Install current Upsun CLI"
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"
PKGS_CONF="$HOME/.config/makaron/packages.conf"

if [ ! -f "$PKGS_CONF" ]; then
    echo "No package selections found, skipping"
    exit 0
fi

source "$PKGS_CONF"
if [[ " ${MAKARON_PACKAGES:-} " != *" upsun "* ]]; then
    echo "Upsun CLI is not selected, skipping"
    exit 0
fi

source "$MAKARON_PATH/install/helpers.sh"
brew_trust --formula "upsun/tap/platformsh-cli" || true

if command -v platform &>/dev/null; then
    echo "Upsun CLI already installed"
    exit 0
fi

if ! install_formula "upsun/tap/platformsh-cli" "Upsun CLI" "platform"; then
    exit 1
fi

if ! command -v platform &>/dev/null; then
    echo "Upsun CLI installation did not provide the platform command" >&2
    exit 1
fi

echo "Migration completed successfully"
