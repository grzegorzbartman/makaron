#!/bin/bash
# Self-contained migrations: effect + idempotency in a throwaway HOME

SWIPE="$REPO/migrations/1793443471.sh"
mkdir -p "$HOME/Library/LaunchAgents" "$HOME/.local/share/aerospace-swipe" "$HOME/.config/aerospace-swipe"
echo '<plist/>' > "$HOME/Library/LaunchAgents/com.acsandmann.swipe.plist"
printf 'AEROSPACE_GAP_SIZE=20\nAEROSPACE_SWIPE_FINGERS=4\nAEROSPACE_SWIPE_NATURAL=true\n' > "$HOME/.config/makaron/makaron.conf"

bash "$SWIPE" >/dev/null && pass "swipe cleanup runs" || fail "swipe cleanup failed"
[ ! -e "$HOME/Library/LaunchAgents/com.acsandmann.swipe.plist" ] && [ ! -e "$HOME/.local/share/aerospace-swipe" ] \
    && pass "swipe files removed" || fail "swipe files left behind"
assert_not_contains "$HOME/.config/makaron/makaron.conf" "AEROSPACE_SWIPE_" "swipe vars removed"
assert_contains "$HOME/.config/makaron/makaron.conf" "AEROSPACE_GAP_SIZE=20" "other user values kept"
bash "$SWIPE" >/dev/null && pass "swipe cleanup idempotent" || fail "second run failed"
