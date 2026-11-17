#!/bin/bash

# Runs overlap while scrolling, so only the newest one draws: the volume_change each step emits always starts after it.
echo $$ > /tmp/sketchybar/volume.latest

case $SENDER in
  mouse.scrolled) osascript -e "set volume output volume (output volume of (get volume settings)) + $SCROLL_DELTA * 2" ;;
  mouse.clicked) osascript -e 'set volume output muted (not output muted of (get volume settings))' ;;
esac

read -r volume muted transport <<< "$("$CONFIG_DIR/helpers/audio_output")"
read -r latest < /tmp/sketchybar/volume.latest
[ "$latest" = $$ ] || exit

if [ "$muted" = true ]; then
  icon=
  label=mute
else
  case $volume in
    0) icon= ;;
    [0-9]|[1-4][0-9]) icon= ;;
    *) icon= ;;
  esac
  label="$volume%"
fi
[ "$transport" = bluetooth ] && icon=""
sketchybar --set "$NAME" icon="$icon" label="$label"
