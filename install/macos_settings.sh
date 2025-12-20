#!/bin/bash

#------------------------------------------------------------------------------
# macOS Settings Configuration Script
# Configures comprehensive macOS settings for optimal use with AeroSpace
#------------------------------------------------------------------------------

# Keyboard settings
configure_keyboard() {
    echo "Setting comfortable keyboard repeat rates..."
    defaults write -g InitialKeyRepeat -int 25 # normal minimum is 15 (225 ms) - slower initial delay
    defaults write -g KeyRepeat -int 3         # normal minimum is 2 (30 ms) - slower repeat rate
    echo "Keyboard repeat rates configured"
}

# Finder preferences
configure_finder() {
    echo "Configuring enhanced Finder settings..."
    defaults write com.apple.finder AppleShowAllFiles YES
    defaults write NSGlobalDomain AppleShowAllExtensions -bool false
    defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
    defaults write com.apple.finder ShowPathbar -bool true
    defaults write com.apple.finder ShowStatusBar -bool true
    defaults write com.apple.finder _FXSortFoldersFirst -bool true
    defaults write com.apple.finder NewWindowTarget -string "PfHm"
    defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"
    defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
    echo "Finder preferences configured"
}

# System preferences
configure_system() {
    echo "Configuring enhanced system and trackpad settings..."
    defaults write com.apple.LaunchServices LSQuarantine -bool false
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true
    defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
    echo "System preferences configured"
}

# Text and input preferences
configure_text_input() {
    echo "Configuring enhanced text and input settings..."
    defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
    defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
    defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
    defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
    defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
    defaults write NSGlobalDomain NSTextMovementDefaultKeyTimeout -float 0.03
    echo "Text input preferences configured"
}

# Save and print dialogs
configure_dialogs() {
    echo "Expanding save and print dialogs by default..."
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true
    echo "Save and print dialogs configured"
}

# Performance and UI enhancements
configure_performance() {
    echo "Optimizing window and UI performance..."
    defaults write NSGlobalDomain NSWindowResizeTime -float 0.001
    defaults write NSGlobalDomain NSToolbarTitleViewRolloverDelay -float 0
    echo "Performance optimizations configured"
}

# Screenshot settings
configure_screenshots() {
    echo "Configuring enhanced screenshot settings..."
    mkdir -p ~/Desktop/Screenshots
    defaults write com.apple.screencapture type -string "png"
    defaults write com.apple.screencapture "include-date" -bool "true"
    defaults write com.apple.screencapture location -string "$HOME/Desktop/Screenshots"
    defaults write com.apple.screencapture disable-shadow -bool true
    echo "Screenshot settings configured"
}

# .DS_Store settings
configure_ds_store() {
    echo "Preventing .DS_Store file creation on network and USB volumes..."
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
    echo ".DS_Store settings configured"
}

# Show Library folder
configure_library_visibility() {
    echo "Making Library folder visible in home directory..."
    chflags nohidden ~/Library
    echo "Library folder made visible"
}

# Dock settings
configure_dock() {
    echo "Configuring Dock settings..."
    defaults write com.apple.dock autohide -bool true
    defaults write com.apple.Dock autohide-delay -float 0
    defaults write com.apple.dock autohide-time-modifier -float 0
    defaults write com.apple.dock expose-animation-duration -float 0.1
    defaults write com.apple.dock springboard-show-duration -int 0
    defaults write com.apple.dock springboard-hide-duration -int 0
    defaults write com.apple.dock springboard-page-duration -int 0
    defaults write com.apple.dock persistent-apps -array
    defaults write com.apple.dock mru-spaces -bool false
    # Enable Mission Control grouping by application (AeroSpace fix)
    defaults write com.apple.dock expose-group-apps -bool true
    echo "Dock preferences configured"
}

# Menu bar autohide
configure_menubar() {
    echo "Configuring menu bar to autohide..."
    defaults write NSGlobalDomain _HIHideMenuBar -bool true
    echo "Menu bar autohide configured"
}

# Accessibility - Reduce transparency
configure_accessibility() {
    echo "Configuring accessibility settings..."
    if defaults write com.apple.universalaccess reduceTransparency -bool true 2>/dev/null; then
        echo "Accessibility settings configured"
    else
        echo "⚠️  Could not enable Reduce Transparency automatically."
        echo "   Please enable manually: System Settings → Accessibility → Display → Reduce transparency"
    fi
}

# iCloud default save
configure_icloud() {
    echo "Setting default save location to local disk instead of iCloud..."
    defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
    echo "Default save location configured"
}

# Disable Apple Intelligence
configure_apple_intelligence() {
    echo "Disabling Apple Intelligence..."
    defaults write com.apple.CloudSubscriptionFeatures.optIn "545129924" -bool "false"
    echo "Apple Intelligence disabled"
}

# Set wallpaper
configure_wallpaper() {
    echo "Setting Tokyo Night wallpaper..."
    local wallpaper_path="$MAKARON_PATH/assets/1-scenery-pink-lakeside-sunset-lake-landscape-scenic-panorama-7680x3215-144.png"
    if [ -f "$wallpaper_path" ]; then
        # Method 1: AppleScript with Finder (most reliable)
        osascript -e "tell application \"Finder\" to set desktop picture to POSIX file \"$wallpaper_path\"" 2>/dev/null

        # Method 2: Database method as fallback
        sqlite3 ~/Library/Application\ Support/Dock/desktoppicture.db "UPDATE data SET value = '$wallpaper_path';" 2>/dev/null
        killall Dock 2>/dev/null

        # Method 3: System Events as additional fallback
        osascript -e "tell application \"System Events\" to tell every desktop to set picture to POSIX file \"$wallpaper_path\"" 2>/dev/null

        echo "Wallpaper set to Tokyo Night theme"
    else
        echo "Warning: Wallpaper file not found at $wallpaper_path"
    fi
}

# Restart affected applications
restart_applications() {
    echo "Applying changes by restarting system components..."
    killall Dock
    killall Finder
    killall SystemUIServer
    echo "Applications restarted"
}

#------------------------------------------------------------------------------
# Main
#------------------------------------------------------------------------------

echo "Configuring macOS settings for optimal use with AeroSpace..."

configure_keyboard
configure_finder
configure_system
configure_text_input
configure_dialogs
configure_performance
configure_screenshots
configure_ds_store
configure_library_visibility
configure_dock
configure_menubar
configure_accessibility
configure_icloud
configure_apple_intelligence
configure_wallpaper
restart_applications

echo ""
echo "macOS settings have been updated successfully!"
