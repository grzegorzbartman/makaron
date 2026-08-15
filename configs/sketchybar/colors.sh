#!/bin/bash

MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"
THEME_HELPERS="$MAKARON_PATH/bin/makaron-theme-helpers"

THEME_LOADED=false
if [ -f "$THEME_HELPERS" ]; then
    # shellcheck source=/dev/null
    source "$THEME_HELPERS"
    load_configured_theme && THEME_LOADED=true
fi

if [ "$THEME_LOADED" != "true" ]; then
    echo "Warning: using built-in Glass Light colors" >&2
    export BAR_COLOR=0x66f5f5f7 BAR_BACKGROUND_COLOR=0x00000000 BAR_BLUR=30
    export ICON_COLOR=0xff1d1d1f LABEL_COLOR=0xff1d1d1f
    export SPACE_ICON_COLOR=0xff3a3a3c SPACE_LABEL_COLOR=0xff3a3a3c
    export SPACE_BACKGROUND_COLOR=0x99ffffff SPACE_BORDER_COLOR=0x00000000
    export SPACE_FOCUSED_ICON_COLOR=0xffffffff SPACE_FOCUSED_LABEL_COLOR=0xffffffff
    export SPACE_FOCUSED_BACKGROUND_COLOR=0xff007aff SPACE_FOCUSED_BORDER_COLOR=0xff007aff
fi
