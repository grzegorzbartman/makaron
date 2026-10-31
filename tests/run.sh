#!/bin/bash
# Runs tests/test_*.sh, each in a throwaway HOME. Usage: tests/run.sh [file...]

REPO="$(cd "$(dirname "$0")/.." && pwd)"
export REPO MAKARON_PATH="$REPO"
FAILED=0

pass() { echo "  ok   $1"; }
fail() { echo "  FAIL $1"; FAILED=1; }
assert_contains() { grep -qF -- "$2" "$1" && pass "$3" || fail "$3 (missing: $2)"; }
assert_not_contains() { grep -qF -- "$2" "$1" && fail "$3 (unexpected: $2)" || pass "$3"; }
assert_eq() { [ "$1" = "$2" ] && pass "$3" || fail "$3 (got '$1', want '$2')"; }
# Line of the first match of $2 in $1 (0 when absent)
line_of() { grep -nF -- "$2" "$1" | head -1 | cut -d: -f1 | grep . || echo 0; }
export -f pass fail assert_contains assert_not_contains assert_eq line_of

[ $# -eq 0 ] && set -- "$REPO"/tests/test_*.sh
for t in "$@"; do
    echo "$(basename "$t")"
    HOME="$(mktemp -d)"
    export HOME
    mkdir -p "$HOME/.config/makaron" "$HOME/.local/state/makaron"
    # shellcheck source=/dev/null
    source "$t"
    rm -rf "$HOME"
done

exit "$FAILED"
