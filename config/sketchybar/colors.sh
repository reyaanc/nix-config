#!/bin/bash

GHOSTTY_CONFIG=$HOME/.config/ghostty/config

ghostty_colors() {
  local line key value
  while IFS= read -r line || [ -n "$line" ]; do
    key=${line%%=*}
    key=${key%% *}
    value=${line#*=}
    value=${value# }
    case $key in
      theme) THEME=$value ;;
      font-family) FONT=$value ;;
      background) BACKGROUND=${value#\#} ;;
      foreground) FOREGROUND=${value#\#} ;;
      palette) printf -v "P${value%%=*}" '%s' "${value#*=#}" ;;
    esac
  done < "$1"
}

mix() {
  local a=$2 b=$3 p=$4
  printf -v "$1" '0xff%02x%02x%02x' \
    $(( (16#${a:0:2} * (100 - p) + 16#${b:0:2} * p) / 100 )) \
    $(( (16#${a:2:2} * (100 - p) + 16#${b:2:2} * p) / 100 )) \
    $(( (16#${a:4:2} * (100 - p) + 16#${b:4:2} * p) / 100 ))
}

# Parsing the Ghostty theme takes ~20ms and this file is sourced on every focus change, so the result is kept until either file changes
# Nix-generated configs are symlinks into the store with a 1970 mtime, so the cache is keyed on where the config resolves to
resolved=$(readlink -f "$GHOSTTY_CONFIG")
COLORS_CACHE=/tmp/sketchybar/colors${resolved//\//_}
if [ -f "$COLORS_CACHE" ] && [ "$COLORS_CACHE" -nt "${BASH_SOURCE[0]}" ]; then
  source "$COLORS_CACHE"
else
  defined=$(compgen -v)

  ghostty_colors "$GHOSTTY_CONFIG"
  for dir in "$HOME/.config/ghostty/themes" /Applications/Ghostty.app/Contents/Resources/ghostty/themes; do
    [ -f "$dir/$THEME" ] && ghostty_colors "$dir/$THEME" && break
  done
  # The config is read again so colours set directly in it override the theme's, as they do in Ghostty.
  ghostty_colors "$GHOSTTY_CONFIG"

  BG0=0xff$P0
  mix BG1 "$BACKGROUND" "$P8" 7
  mix BG2 "$BACKGROUND" "$P8" 22
  mix BG3 "$BACKGROUND" "$P8" 45

  TEXT=0xff$FOREGROUND
  SUBTEXT=0xff$P7
  mix DIM "$P8" "$FOREGROUND" 50
  mix MUTED "$P8" "$FOREGROUND" 20
  ACCENT=0xff$P4
  PURPLE=0xff$P5
  GREEN=0xff$P2
  mix DULL_GREEN "$P2" "$P8" 30
  WARN=0xff$P3
  mix ORANGE "$P3" "$P1" 35
  CRIT=0xff$P1

  BAR_ALPHA=99
  SEGMENT_ALPHA=30
  STATUS_ALPHA=80
  FOCUSED_ALPHA=d9

  BAR_COLOR=0x$BAR_ALPHA${BG0:4}
  BASE=$BG0
  TRANSPARENT=0x00000000

  MENU_BG=$TRANSPARENT
  WS_BG=0x$SEGMENT_ALPHA${BG1:4}
  WS_FOCUSED=0x$FOCUSED_ALPHA${BG3:4}
  POPUP_BORDER=$BG3
  POPUP_HOVER=$BG2

  VOLUME_BG=0x$STATUS_ALPHA${BG1:4}
  BATTERY_BG=0x$STATUS_ALPHA${BG2:4}
  CLOCK_BG=0x$STATUS_ALPHA${BG3:4}
  VOLUME_ICON=$PURPLE
  BATTERY_ICON=$GREEN

  mkdir -p /tmp/sketchybar
  declare -p $(compgen -v | grep -vxF "$defined" | grep -vx defined) > "$COLORS_CACHE.$$"
  mv "$COLORS_CACHE.$$" "$COLORS_CACHE"
fi

# Firefox profiles are told apart by avatar colour; red is left out since a red dot reads as an unread badge.
__profile_color() {
  case $1 in
    heart) profile=$P5 ;;
    star) profile=$P3 ;;
    flower) profile=$P2 ;;
    book) profile=$P4 ;;
    briefcase) profile=${ORANGE:4} ;;
    shopping) profile=$P6 ;;
    *) profile= ;;
  esac
}

__brand_color() {
  case $1 in
    Slack) brand=611f69 ;;
    Discord) brand=5865f2 ;;
    Ghostty) brand=3551f3 ;;
    Herdr) brand=7aa2f7 ;;
    "Google Chrome") brand=fbbc04 ;;
    Firefox) brand=ff7139 ;;
    Finder) brand=1e9bf0 ;;
    1Password) brand=0572ec ;;
    Spotify) brand=1db954 ;;
    Todoist) brand=e44332 ;;
    Thunderbird) brand=0a84ff ;;
    Postman) brand=ff6c37 ;;
    Preview) brand=5ac8fa ;;
    zoom.us) brand=0b5cff ;;
    "System Settings") brand=8e8e93 ;;
    *) brand= ;;
  esac
}
