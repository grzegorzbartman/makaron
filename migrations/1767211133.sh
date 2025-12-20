#!/bin/bash
# Migration: Restore default file extension visibility
# Reverts AppleShowAllExtensions to system default (false)

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Restore default file extension visibility"

defaults write NSGlobalDomain AppleShowAllExtensions -bool false
killall Finder 2>/dev/null || true

echo "Migration completed successfully"

