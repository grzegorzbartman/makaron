#!/bin/bash

# Migration: Install new tools and applications
# Adds installation scripts for htop, tree, jq, gh, ffmpeg, discord, zulip, vlc, spotify, obs, gimp, inkscape, steam

set -e

error_exit() {
  echo -e "\033[31mERROR: Migration failed! Manual intervention required.\033[0m" >&2
  exit 1
}

trap error_exit ERR

echo "Running migration: Install new tools and applications"

# Set MAKARON_PATH if not already set
MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"

# Install tools
if [ -f "$MAKARON_PATH/install/tools/htop.sh" ]; then
    echo "Installing htop..."
    source "$MAKARON_PATH/install/tools/htop.sh"
else
    echo "htop installation script not found, skipping"
fi

if [ -f "$MAKARON_PATH/install/tools/tree.sh" ]; then
    echo "Installing tree..."
    source "$MAKARON_PATH/install/tools/tree.sh"
else
    echo "tree installation script not found, skipping"
fi

if [ -f "$MAKARON_PATH/install/tools/jq.sh" ]; then
    echo "Installing jq..."
    source "$MAKARON_PATH/install/tools/jq.sh"
else
    echo "jq installation script not found, skipping"
fi

if [ -f "$MAKARON_PATH/install/tools/gh.sh" ]; then
    echo "Installing GitHub CLI..."
    source "$MAKARON_PATH/install/tools/gh.sh"
else
    echo "GitHub CLI installation script not found, skipping"
fi

if [ -f "$MAKARON_PATH/install/tools/ffmpeg.sh" ]; then
    echo "Installing ffmpeg..."
    source "$MAKARON_PATH/install/tools/ffmpeg.sh"
else
    echo "ffmpeg installation script not found, skipping"
fi

# Install UI applications
if [ -f "$MAKARON_PATH/install/ui/discord.sh" ]; then
    echo "Installing Discord..."
    source "$MAKARON_PATH/install/ui/discord.sh"
else
    echo "Discord installation script not found, skipping"
fi

if [ -f "$MAKARON_PATH/install/ui/zulip.sh" ]; then
    echo "Installing Zulip..."
    source "$MAKARON_PATH/install/ui/zulip.sh"
else
    echo "Zulip installation script not found, skipping"
fi

if [ -f "$MAKARON_PATH/install/ui/vlc.sh" ]; then
    echo "Installing VLC..."
    source "$MAKARON_PATH/install/ui/vlc.sh"
else
    echo "VLC installation script not found, skipping"
fi

if [ -f "$MAKARON_PATH/install/ui/spotify.sh" ]; then
    echo "Installing Spotify..."
    source "$MAKARON_PATH/install/ui/spotify.sh"
else
    echo "Spotify installation script not found, skipping"
fi

if [ -f "$MAKARON_PATH/install/ui/obs.sh" ]; then
    echo "Installing OBS..."
    source "$MAKARON_PATH/install/ui/obs.sh"
else
    echo "OBS installation script not found, skipping"
fi

if [ -f "$MAKARON_PATH/install/ui/gimp.sh" ]; then
    echo "Installing GIMP..."
    source "$MAKARON_PATH/install/ui/gimp.sh"
else
    echo "GIMP installation script not found, skipping"
fi

if [ -f "$MAKARON_PATH/install/ui/inkscape.sh" ]; then
    echo "Installing Inkscape..."
    source "$MAKARON_PATH/install/ui/inkscape.sh"
else
    echo "Inkscape installation script not found, skipping"
fi

if [ -f "$MAKARON_PATH/install/ui/steam.sh" ]; then
    echo "Installing Steam..."
    source "$MAKARON_PATH/install/ui/steam.sh"
else
    echo "Steam installation script not found, skipping"
fi

# Individual installation scripts check if applications are already installed (idempotent)
echo "Migration completed successfully"

