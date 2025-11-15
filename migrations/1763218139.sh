#!/bin/bash

# Migration: Uninstall SwipeAeroSpace
# Removes SwipeAeroSpace as it conflicts with 3-finger Mission Control gesture

set -e

error_exit() {
  echo -e "\033[31mERROR: Migration failed! Manual intervention required.\033[0m" >&2
  exit 1
}

trap error_exit ERR

echo "Running migration: Uninstall SwipeAeroSpace"

# Check if SwipeAeroSpace is installed
if brew list --cask mediosz/tap/swipeaerospace &> /dev/null; then
    echo "Uninstalling SwipeAeroSpace..."
    
    # Quit SwipeAeroSpace if running
    if pgrep -f "SwipeAeroSpace" > /dev/null; then
        echo "Stopping SwipeAeroSpace..."
        killall SwipeAeroSpace 2>/dev/null || true
    fi
    
    # Remove from login items
    osascript -e 'tell application "System Events" to delete login item "SwipeAeroSpace"' 2>/dev/null || true
    
    # Uninstall via brew
    brew uninstall --cask mediosz/tap/swipeaerospace 2>/dev/null || true
    
    echo "✓ SwipeAeroSpace uninstalled"
else
    echo "SwipeAeroSpace not installed, skipping"
fi

echo "Migration completed successfully"

