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

# makaron-migrate: runs only pending migrations from MAKARON_PATH, real ANSI colors
STATE="$HOME/.local/state/makaron/migrations"
mkdir -p "$STATE"
for f in "$REPO"/migrations/*.sh; do [ "$f" = "$SWIPE" ] || touch "$STATE/$(basename "$f")"; done
OUT="$HOME/migrate.out"
/bin/bash "$REPO/bin/makaron-migrate" > "$OUT" 2>&1
assert_contains "$OUT" "Running migration (1793443471)" "makaron-migrate runs the pending migration"
[ -f "$STATE/1793443471.sh" ] && pass "pending migration marked completed" || fail "state file missing"
assert_not_contains "$OUT" '\e[' "no literal \\e escapes (bash 3.2)"
/bin/bash "$REPO/bin/makaron-migrate" > "$OUT" 2>&1
assert_not_contains "$OUT" "Running migration (" "second run has nothing pending"

# Laptop gap default 0 -> 2: bumps only the old default, leaves other values
GAP="$REPO/migrations/1793534390.sh"
printf 'AEROSPACE_GAP_SIZE=12\nAEROSPACE_GAP_SIZE_LAPTOP=0\n' > "$HOME/.config/makaron/makaron.conf"
bash "$GAP" >/dev/null && pass "gap migration runs" || fail "gap migration failed"
assert_contains "$HOME/.config/makaron/makaron.conf" "AEROSPACE_GAP_SIZE_LAPTOP=2" "laptop gap bumped to 2"
assert_contains "$HOME/.config/makaron/makaron.conf" "AEROSPACE_GAP_SIZE=12" "desktop gap untouched"
printf 'AEROSPACE_GAP_SIZE_LAPTOP=6\n' > "$HOME/.config/makaron/makaron.conf"
bash "$GAP" >/dev/null
assert_contains "$HOME/.config/makaron/makaron.conf" "AEROSPACE_GAP_SIZE_LAPTOP=6" "custom laptop gap kept"
bash "$GAP" >/dev/null && pass "gap migration idempotent" || fail "gap migration second run failed"
