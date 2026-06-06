#!/bin/bash
# Migration: Remove unsupported Dozer
#
# Dozer is no longer supported. Stop it if running, uninstall the Homebrew cask
# when present, and remove the old optional package selection.

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Remove unsupported Dozer"

PACKAGES_CONF="${MAKARON_PACKAGES_CONF:-$HOME/.config/makaron/packages.conf}"

if pgrep -x Dozer >/dev/null 2>&1; then
    echo "  Quitting Dozer..."
    osascript -e 'tell application "Dozer" to quit' >/dev/null 2>&1 || true
    sleep 1

    if pgrep -x Dozer >/dev/null 2>&1; then
        killall Dozer 2>/dev/null || true
    fi
fi

if command -v brew >/dev/null 2>&1; then
    if brew list --cask dozer >/dev/null 2>&1; then
        echo "  Uninstalling Dozer cask..."
        brew uninstall --cask dozer || {
            echo "  Warning: failed to uninstall Dozer cask, continuing"
        }
    else
        echo "  Dozer cask is not installed"
    fi
else
    echo "  Homebrew not found, skipping cask uninstall"
fi

if [ -f "$PACKAGES_CONF" ] && grep -q '^MAKARON_PACKAGES=' "$PACKAGES_CONF" 2>/dev/null; then
    # shellcheck source=/dev/null
    source "$PACKAGES_CONF"
    cleaned_packages=""

    for package in $MAKARON_PACKAGES; do
        [ "$package" = "dozer" ] && continue
        cleaned_packages="$cleaned_packages $package"
    done

    cleaned_packages=$(echo "$cleaned_packages" | xargs)

    if [ "${MAKARON_PACKAGES:-}" != "$cleaned_packages" ]; then
        sed -i '' "s/^MAKARON_PACKAGES=.*/MAKARON_PACKAGES=\"$cleaned_packages\"/" "$PACKAGES_CONF"
        echo "  Removed Dozer from package selections"
    fi
fi

echo "Migration completed successfully"
