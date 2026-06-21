#!/bin/bash
# Migration: Remove AltTab
#
# AltTab is no longer offered by Makaron. Remove the app for existing users and
# drop the old optional package selection so updates do not try to reinstall it.

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Remove AltTab"

PACKAGES_CONF="${MAKARON_PACKAGES_CONF:-$HOME/.config/makaron/packages.conf}"

osascript -e 'tell application "AltTab" to quit' >/dev/null 2>&1 || true
killall AltTab 2>/dev/null || true

if command -v brew >/dev/null 2>&1 && brew list --cask alt-tab >/dev/null 2>&1; then
    brew uninstall --cask alt-tab 2>/dev/null || true
fi

rm -rf "/Applications/AltTab.app"

if [ -f "$PACKAGES_CONF" ] && grep -q '^MAKARON_PACKAGES=' "$PACKAGES_CONF" 2>/dev/null; then
    # shellcheck source=/dev/null
    source "$PACKAGES_CONF"
    cleaned_packages=""

    for package in $MAKARON_PACKAGES; do
        [ "$package" = "alttab" ] && continue
        cleaned_packages="$cleaned_packages $package"
    done

    cleaned_packages=$(echo "$cleaned_packages" | xargs)

    if [ "${MAKARON_PACKAGES:-}" != "$cleaned_packages" ]; then
        sed -i '' "s/^MAKARON_PACKAGES=.*/MAKARON_PACKAGES=\"$cleaned_packages\"/" "$PACKAGES_CONF"
        echo "  Removed AltTab from package selections"
    fi
fi

echo "Migration completed successfully"
