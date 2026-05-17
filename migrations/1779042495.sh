#!/bin/bash
# Migration: Unify desktop layout state (issue #49)
#
# - Unifies BORDER_WIDTH=5.0 in macos-default-{dark,light} (was 2.0). Repo
#   already ships the updated value; this guards against users that ran the
#   update mid-theme-switch and still have stale copies.
# - Heals ~/.aerospace.toml by calling apply_desktop_state, which re-derives
#   gaps, outer.top and borders process state from ui-mode + makaron.conf.
# - Restarts borders so the new (unified) BORDER_WIDTH takes effect.
# Idempotent: safe to re-run.

set -e
error_exit() { echo -e "\033[31mERROR: Migration failed!\033[0m" >&2; exit 1; }
trap error_exit ERR

echo "Running migration: Unify desktop layout state (issue #49)"

MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"

# Force BORDER_WIDTH=5.0 in macos-default themes (defensive — main file
# should already be 5.0 from git reset --hard).
for theme in macos-default-dark macos-default-light; do
    f="$MAKARON_PATH/themes/$theme/borders.colors"
    [ ! -f "$f" ] && continue
    if grep -qE '^export BORDER_WIDTH=2\.0' "$f"; then
        sed -i '' 's/^export BORDER_WIDTH=2\.0/export BORDER_WIDTH=5.0/' "$f"
        echo "  Unified BORDER_WIDTH=5.0 in $theme"
    fi
done

# Heal ~/.aerospace.toml and borders process via the new single source of truth.
UI_HELPERS="$MAKARON_PATH/bin/makaron-ui-helpers"
if [ -f "$UI_HELPERS" ]; then
    # shellcheck source=/dev/null
    source "$UI_HELPERS"
    if [ "$(get_ui_mode 2>/dev/null || echo full)" != "stop" ]; then
        echo "  Re-applying desktop state..."
        apply_desktop_state || true
    else
        echo "  UI mode is 'stop' — skipping live re-apply"
    fi
fi

echo "Migration completed successfully"
