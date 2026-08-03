#!/bin/bash
# Migration: Trust Makaron's Homebrew taps
# Homebrew >= 6.0 refuses to load non-official taps until they are trusted, so
# existing installs silently stop upgrading SketchyBar/AeroSpace and the
# `brew autoupdate` external command fails outright.

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Trust Makaron's Homebrew taps"

if ! brew trust --json=v1 &>/dev/null; then
    echo "Homebrew tap trust not supported, skipping"
    exit 0
fi

trust() { brew trust "$1" "$2" &>/dev/null || echo "Warning: could not trust $2"; }

trust --formula felixkratz/formulae/sketchybar
trust --cask nikitabobko/tap/aerospace
trust --command domt4/autoupdate/autoupdate

if command -v ddev &>/dev/null; then
    trust --formula ddev/ddev/ddev
fi

if command -v upsun &>/dev/null; then
    trust --formula platformsh/tap/upsun-cli
fi

echo "Migration completed successfully"
