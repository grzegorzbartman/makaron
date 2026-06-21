#!/bin/bash
# Migration: Retire Ice menu bar manager
# Ice is no longer managed by Makaron.

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Retire Ice menu bar manager"

PACKAGES_CONF="${MAKARON_PACKAGES_CONF:-$HOME/.config/makaron/packages.conf}"

if [ -f "$PACKAGES_CONF" ]; then
    # shellcheck source=/dev/null
    source "$PACKAGES_CONF"
    if [[ " ${MAKARON_PACKAGES:-} " == *" ice "* ]]; then
        updated_packages=$(echo "${MAKARON_PACKAGES:-}" | tr ' ' '\n' | { grep -v '^ice$' || true; } | sort -u | tr '\n' ' ' | xargs)
        cat > "$PACKAGES_CONF" << EOF
# Makaron package selections
# Re-run selection: makaron-select-packages
MAKARON_PACKAGES="$updated_packages"
EOF
        echo "  Removed Ice from package selections"
    fi
fi

echo "Migration completed successfully"
