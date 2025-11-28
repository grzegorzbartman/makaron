#!/bin/bash
# Migration: Battery low warning feature
# Reloads sketchybar to apply updated battery.sh script

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Battery low warning feature"

# Reload sketchybar to apply new battery script
killall sketchybar 2>/dev/null || true
sleep 1
sketchybar &

echo "Migration completed successfully"
