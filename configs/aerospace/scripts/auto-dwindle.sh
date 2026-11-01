#!/bin/bash
# Auto dwindle layout - inspired by Hyprland
# Automatically arranges windows in a spiral/dwindle pattern:
# - 1 window: full screen
# - 2 windows: 50/50 horizontal split
# - 3 windows: master 50% + stack (2 windows vertically)
# - 4+ windows: equal quadrants (each window 25%)

sleep 0.05
# A stacked (accordion) workspace has nothing to split; tiles-guard.sh owns it
case "$(aerospace list-windows --focused --format '%{workspace-root-container-layout}' 2>/dev/null)" in
    *accordion) exit 0 ;;
esac
COUNT=$(aerospace list-windows --workspace focused --count 2>/dev/null)
[ -z "$COUNT" ] && exit 0

if [ "$COUNT" -eq 3 ]; then
    # 3rd window: create master-stack (join with window to the left)
    aerospace join-with left
elif [ "$COUNT" -ge 4 ]; then
    LAYOUT=$(aerospace list-windows --focused --format '%{window-parent-container-layout}' 2>/dev/null)
    if [ "$LAYOUT" = "v_tiles" ]; then
        # In vertical stack - join horizontally with adjacent window
        aerospace join-with left
    elif [ "$LAYOUT" = "h_tiles" ]; then
        # In horizontal layout - join vertically with adjacent window
        aerospace join-with up
    fi
fi
