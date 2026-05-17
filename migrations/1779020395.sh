#!/bin/bash
# Migration: AeroSpace event-model improvements + remove timer/todoist/calendar widgets
#
# - Picks up the new on-focus-changed callback and PREV_WORKSPACE payload by
#   reloading AeroSpace and SketchyBar configs.
# - Adds SKETCHYBAR_HIDE_EMPTY_WORKSPACES to makaron.conf with the default
#   `false`, preserving any existing value the user may have already set.
# - Removes the obsolete SKETCHYBAR_TIMER_*, SKETCHYBAR_TODOIST_ENABLED and
#   SKETCHYBAR_CALENDAR_ENABLED entries from makaron.conf. Existing
#   Timewarrior / Todoist CLI installs and their data are left untouched.

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: AeroSpace event-model improvements + widget cleanup"

MAKARON_CONF="${MAKARON_CONF:-$HOME/.config/makaron/makaron.conf}"

# 1. makaron.conf: add SKETCHYBAR_HIDE_EMPTY_WORKSPACES if missing
if [ -f "$MAKARON_CONF" ]; then
    if ! grep -q '^SKETCHYBAR_HIDE_EMPTY_WORKSPACES=' "$MAKARON_CONF" 2>/dev/null; then
        echo "" >> "$MAKARON_CONF"
        echo "# SketchyBar: hide empty AeroSpace workspaces from the bar" >> "$MAKARON_CONF"
        echo "# The focused workspace is always drawn, even if it's empty." >> "$MAKARON_CONF"
        echo "SKETCHYBAR_HIDE_EMPTY_WORKSPACES=false" >> "$MAKARON_CONF"
        echo "  Added SKETCHYBAR_HIDE_EMPTY_WORKSPACES=false to $MAKARON_CONF"
    else
        echo "  SKETCHYBAR_HIDE_EMPTY_WORKSPACES already present, leaving as-is"
    fi

    # 2. makaron.conf: strip obsolete widget config (the widgets themselves
    #    are gone from the codebase; leaving stale entries is just noise).
    if grep -qE '^(SKETCHYBAR_TIMER_|SKETCHYBAR_TODOIST_ENABLED|SKETCHYBAR_CALENDAR_ENABLED|TODOIST_CLI)' "$MAKARON_CONF" 2>/dev/null; then
        # Match the variable line and any immediately preceding comment block.
        # Comments associated with removed widgets are dropped too.
        tmp_conf="$(mktemp)"
        awk '
            BEGIN { buf = ""; in_block = 0 }
            /^#/ {
                buf = (buf == "" ? $0 : buf "\n" $0)
                next
            }
            /^SKETCHYBAR_TIMER_/ ||
            /^SKETCHYBAR_TODOIST_ENABLED/ ||
            /^SKETCHYBAR_CALENDAR_ENABLED/ ||
            /^TODOIST_CLI/ {
                buf = ""
                next
            }
            {
                if (buf != "") {
                    print buf
                    buf = ""
                }
                print
            }
            END {
                if (buf != "") print buf
            }
        ' "$MAKARON_CONF" > "$tmp_conf"
        mv "$tmp_conf" "$MAKARON_CONF"
        echo "  Removed obsolete widget config entries from $MAKARON_CONF"
    fi
else
    echo "  $MAKARON_CONF not present, skipping config edits"
fi

# 3. Reload AeroSpace so on-focus-changed + PREV_WORKSPACE payload take effect
if command -v aerospace >/dev/null 2>&1; then
    if aerospace reload-config 2>/dev/null; then
        echo "  AeroSpace config reloaded"
    else
        echo "  Warning: aerospace reload-config failed (will pick up on next launch)"
    fi
fi

# 4. Reload SketchyBar so the new event subscriptions and removed items apply
if command -v sketchybar >/dev/null 2>&1 && pgrep -x sketchybar >/dev/null 2>&1; then
    if sketchybar --reload 2>/dev/null; then
        echo "  SketchyBar reloaded"
    else
        echo "  Warning: sketchybar --reload failed (will pick up on next launch)"
    fi
fi

echo "Migration completed successfully"
