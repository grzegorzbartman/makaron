#!/bin/bash
# Migration: Remove Sol
# Uninstalls Sol launcher

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Remove Sol"

if brew list --cask sol &>/dev/null; then
    brew uninstall --cask sol
    echo "Sol uninstalled"
else
    echo "Sol not installed, skipping"
fi

echo "Migration completed successfully"
