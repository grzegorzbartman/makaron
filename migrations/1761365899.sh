#!/bin/bash

# Migration: Enable Dock autohide, Menu Bar autohide, and Reduce Transparency
# Applies accessibility and UI settings for better AeroSpace integration

echo "Running migration: Enable Dock autohide, Menu Bar autohide, and Reduce Transparency"

# Check if settings are already applied (idempotent)
DOCK_AUTOHIDE=$(defaults read com.apple.dock autohide 2>/dev/null || echo "0")
MENUBAR_AUTOHIDE=$(defaults read NSGlobalDomain _HIHideMenuBar 2>/dev/null || echo "0")
REDUCE_TRANSPARENCY=$(defaults read com.apple.universalaccess reduceTransparency 2>/dev/null || echo "0")

if [ "$DOCK_AUTOHIDE" = "1" ] && [ "$MENUBAR_AUTOHIDE" = "1" ] && [ "$REDUCE_TRANSPARENCY" = "1" ]; then
    echo "Settings already applied, skipping"
    exit 0
fi

# Apply Dock autohide
if [ "$DOCK_AUTOHIDE" != "1" ]; then
    echo "Enabling Dock autohide..."
    if defaults write com.apple.dock autohide -bool true 2>/dev/null; then
        echo "✓ Dock autohide enabled"
    else
        echo "⚠️  Could not enable Dock autohide automatically."
        echo "   Please enable manually: System Settings → Desktop & Dock → Automatically hide and show the Dock"
    fi
fi

# Apply Menu Bar autohide (always)
if [ "$MENUBAR_AUTOHIDE" != "1" ]; then
    echo "Enabling Menu Bar autohide (always)..."
    if [ -f "$HOME/.local/share/makaron/bin/makaron-ui-helpers" ]; then
        source "$HOME/.local/share/makaron/bin/makaron-ui-helpers"
        if _set_menubar_autohide "Always"; then
            echo "✓ Menu Bar autohide enabled"
        elif defaults write NSGlobalDomain _HIHideMenuBar -bool true 2>/dev/null; then
            echo "✓ Menu Bar autohide preference updated"
            echo "  Note: macOS Sequoia may ignore this until changed via System Settings UI"
        else
            echo "⚠️  Could not enable Menu Bar autohide automatically."
            echo "   Please enable manually: System Settings → Control Center → Menu Bar → Automatically hide and show the menu bar → Always"
        fi
    elif defaults write NSGlobalDomain _HIHideMenuBar -bool true 2>/dev/null; then
        echo "✓ Menu Bar autohide enabled"
    else
        echo "⚠️  Could not enable Menu Bar autohide automatically."
        echo "   Please enable manually: System Settings → Control Center → Menu Bar → Automatically hide and show the menu bar → Always"
    fi
fi

# Apply Reduce Transparency
if [ "$REDUCE_TRANSPARENCY" != "1" ]; then
    echo "Enabling Reduce Transparency..."
    if defaults write com.apple.universalaccess reduceTransparency -bool true 2>/dev/null; then
        echo "✓ Reduce Transparency enabled"
    else
        echo "⚠️  Could not enable Reduce Transparency automatically."
        echo "   Please enable manually: System Settings → Accessibility → Display → Reduce transparency"
    fi
fi

# Restart Dock and SystemUIServer to apply changes
echo "Applying changes..."
killall Dock 2>/dev/null || true
killall SystemUIServer 2>/dev/null || true

echo "Migration completed"
echo "Note: You may need to log out and log back in for Menu Bar changes to take full effect"

