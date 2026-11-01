#!/bin/bash
# Laptop profile: at most AEROSPACE_LAPTOP_MAX_TILES tiled windows side by side.
# One more flips the focused workspace to accordion (a stack); back at or under
# the limit a workspace we flipped returns to tiles. A workspace the user flips
# back by hand (alt-slash) is left alone until it drops under the limit again.
# Runs from on-focus-changed: new and closed windows both move focus.

MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"
# shellcheck source=/dev/null
source "$MAKARON_PATH/bin/makaron-ui-helpers" 2>/dev/null || exit 0

max=$(_get_max_tiles)
[ "$max" -gt 0 ] 2>/dev/null || exit 0

sleep 0.2  # let auto-dwindle place a new window first
ws=$(aerospace list-workspaces --focused 2>/dev/null)
[ -n "$ws" ] || exit 0

rows=$(aerospace list-windows --workspace "$ws" --format '%{window-layout}|%{workspace-root-container-layout}' 2>/dev/null)
tiled=0
[ -n "$rows" ] && tiled=$(printf '%s\n' "$rows" | grep -cv '^floating|')
root=$(printf '%s\n' "$rows" | head -1 | cut -d'|' -f2)
state="/tmp/makaron-$(id -u)-tiles-guard-$ws"

if [ "$tiled" -gt "$max" ]; then
    case "$root" in
        *accordion) ;;
        *)
            if [ -f "$state" ]; then
                echo user > "$state"  # flipped by us, undone by the user: respect it
            else
                aerospace flatten-workspace-tree --workspace "$ws" 2>/dev/null
                aerospace layout --workspace "$ws" --root h_accordion 2>/dev/null && echo auto > "$state"
            fi
            ;;
    esac
elif [ -f "$state" ]; then
    case "$root" in
        *accordion) [ "$(cat "$state")" = auto ] && aerospace layout --workspace "$ws" --root h_tiles 2>/dev/null ;;
    esac
    rm -f "$state"
fi
