#!/bin/bash

# Liquid glass palette following the system appearance.
# plugins/appearance_change.sh reloads the bar when the appearance flips.
if defaults read -g AppleInterfaceStyle >/dev/null 2>&1; then
    # Dark: dark translucent glass, white overlays, dark-mode system blue
    export BAR_COLOR=0x661c1c1e
    export BAR_BACKGROUND_COLOR=0x00000000
    export BAR_BLUR=60
    export BAR_BORDER_COLOR=0x26ffffff

    export ICON_COLOR=0xfff5f5f7
    export LABEL_COLOR=0xfff5f5f7

    export SPACE_ICON_COLOR=0xffd1d1d6
    export SPACE_LABEL_COLOR=0xffd1d1d6
    export SPACE_BACKGROUND_COLOR=0x33ffffff
    export SPACE_BORDER_COLOR=0x00000000

    export SPACE_FOCUSED_ICON_COLOR=0xffffffff
    export SPACE_FOCUSED_LABEL_COLOR=0xffffffff
    export SPACE_FOCUSED_BACKGROUND_COLOR=0xff0a84ff
    export SPACE_FOCUSED_BORDER_COLOR=0xff0a84ff

    export ALERT_COLOR=0xffff453a
    export ALERT_BACKGROUND_COLOR=0x33ff453a
else
    # Light: translucent glass, dark text, system blue
    export BAR_COLOR=0x66f5f5f7
    export BAR_BACKGROUND_COLOR=0x00000000
    export BAR_BLUR=60
    export BAR_BORDER_COLOR=0x40ffffff

    export ICON_COLOR=0xff1d1d1f
    export LABEL_COLOR=0xff1d1d1f

    export SPACE_ICON_COLOR=0xff3a3a3c
    export SPACE_LABEL_COLOR=0xff3a3a3c
    export SPACE_BACKGROUND_COLOR=0x73ffffff
    export SPACE_BORDER_COLOR=0x00000000

    export SPACE_FOCUSED_ICON_COLOR=0xffffffff
    export SPACE_FOCUSED_LABEL_COLOR=0xffffffff
    export SPACE_FOCUSED_BACKGROUND_COLOR=0xff007AFF
    export SPACE_FOCUSED_BORDER_COLOR=0xff007AFF

    export ALERT_COLOR=0xffff3b30
    export ALERT_BACKGROUND_COLOR=0x26ff3b30
fi

# User color overrides (sourced by sketchybarrc and every plugin)
# shellcheck disable=SC1090
[ -f "$HOME/.config/makaron/colors.user.sh" ] && source "$HOME/.config/makaron/colors.user.sh"
