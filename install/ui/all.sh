#!/bin/bash

# Source all UI installation scripts
source "$MAKARON_PATH/install/ui/fonts.sh"
source "$MAKARON_PATH/install/ui/borders.sh"
source "$MAKARON_PATH/install/ui/aerospace.sh"
source "$MAKARON_PATH/install/ui/sketchybar.sh"
source "$MAKARON_PATH/install/ui/swipeaerospace.sh"
source "$MAKARON_PATH/install/ui/chatgpt.sh"
source "$MAKARON_PATH/install/ui/codex.sh"
source "$MAKARON_PATH/install/ui/command-x.sh"
source "$MAKARON_PATH/install/ui/discord.sh"
source "$MAKARON_PATH/install/ui/dozer.sh"
source "$MAKARON_PATH/install/ui/gimp.sh"
source "$MAKARON_PATH/install/ui/inkscape.sh"
source "$MAKARON_PATH/install/ui/obs.sh"
source "$MAKARON_PATH/install/ui/spotify.sh"
source "$MAKARON_PATH/install/ui/steam.sh"
source "$MAKARON_PATH/install/ui/sublime-text.sh"
source "$MAKARON_PATH/install/ui/vlc.sh"
source "$MAKARON_PATH/install/ui/zulip.sh"

# Initialize default theme (tokyo-night)
echo "Setting up default theme (Tokyo Night)..."
if [ ! -L "$MAKARON_PATH/current-theme" ]; then
    ln -s "$MAKARON_PATH/themes/tokyo-night" "$MAKARON_PATH/current-theme"
    echo "Default theme set to Tokyo Night"
fi

