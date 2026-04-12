#!/bin/bash
# Shared: narrowest display width -> SketchyBar label.max_chars.
# Uses minimum across all displays so q/e items fit every screen.
# Caches for 60s; call makaron_invalidate_screen_cache to force refresh.

_SCREEN_CACHE="/tmp/makaron_screen_width"
_SCREEN_CACHE_TTL=60

makaron_invalidate_screen_cache() {
  rm -f "$_SCREEN_CACHE" 2>/dev/null
}

makaron_min_display_width() {
  if [ -f "$_SCREEN_CACHE" ]; then
    local age
    age=$(( $(date +%s) - $(stat -f %m "$_SCREEN_CACHE" 2>/dev/null || echo 0) ))
    if [ "$age" -lt "$_SCREEN_CACHE_TTL" ]; then
      cat "$_SCREEN_CACHE"
      return
    fi
  fi
  local w
  w=$(swift -e 'import AppKit; let ws = NSScreen.screens.map { Int($0.frame.size.width) }; print(ws.min() ?? 1440)' 2>/dev/null) || w=1440
  echo "$w" > "$_SCREEN_CACHE" 2>/dev/null
  echo "$w"
}

# Thresholds tuned for Hack Nerd Font Bold 12pt in q/e positions:
#   <1400  → 18 chars  (small/scaled displays)
#   <1550  → 25 chars  (MacBook Air 13" 1470, MacBook Pro 14" 1512)
#   <1800  → 35 chars  (MacBook Pro 16" 1728)
#   <2560  → 45 chars  (QHD / 1440p external)
#   >=2560 → 55 chars  (4K / ultrawide)
makaron_label_max_chars() {
  local w="${1:-}"
  [ -z "$w" ] && w=$(makaron_min_display_width)
  w="${w//[^0-9]/}"
  [ -z "$w" ] && w=1440
  if   [ "$w" -lt 1400 ]; then echo 18
  elif [ "$w" -lt 1550 ]; then echo 25
  elif [ "$w" -lt 1800 ]; then echo 35
  elif [ "$w" -lt 2560 ]; then echo 45
  else echo 55
  fi
}

# Calendar on the e-slot has much less room than q/right items on small screens.
# Use a tighter cap so it does not overlap the system widgets.
makaron_calendar_label_max_chars() {
  local w="${1:-}"
  [ -z "$w" ] && w=$(makaron_min_display_width)
  w="${w//[^0-9]/}"
  [ -z "$w" ] && w=1440
  if   [ "$w" -lt 1450 ]; then echo 5
  elif [ "$w" -lt 1550 ]; then echo 8
  elif [ "$w" -lt 1720 ]; then echo 10
  elif [ "$w" -lt 1800 ]; then echo 12
  elif [ "$w" -lt 2560 ]; then echo 22
  else echo 32
  fi
}
