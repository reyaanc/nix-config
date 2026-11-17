#!/bin/bash

source "$CONFIG_DIR/colors.sh"

if [ "$SENDER" = "mouse.exited" ]; then
  sketchybar --set "$NAME" popup.drawing=off
  exit
fi

batt=$(pmset -g batt)
percentage=$(grep -Eo '[0-9]+%' <<< "$batt" | tr -d %)

case $percentage in
  100|9[0-9]) icon= ;;
  [6-8][0-9]) icon= ;;
  [3-5][0-9]) icon= ;;
  [1-2][0-9]) icon= ;;
  *) icon= ;;
esac

# The bolt is narrower than the battery glyphs, so it's nudged right to sit centred where they do.
icon_pad=12
grep -q "'AC Power'" <<< "$batt" && icon_pad=15 icon=

icon_color=$BATTERY_ICON
label_color=$SUBTEXT
[ "$percentage" -le 50 ] && icon_color=$DULL_GREEN
[ "$percentage" -le 20 ] && icon_color=$ORANGE label_color=$ORANGE
[ "$percentage" -le 10 ] && icon_color=$CRIT label_color=$CRIT

sketchybar --set "$NAME" icon="$icon" icon.padding_left=$icon_pad label="$percentage%" icon.color=$icon_color label.color=$label_color

if [ "$SENDER" = "mouse.entered" ]; then
  time=$(grep -Eo '[0-9]+:[0-9]{2} remaining' <<< "$batt" | cut -d' ' -f1)
  case $batt in
    *"; charging;"*) details="Charging${time:+, full in $time}" ;;
    *"not charging"*|*"; charged;"*) details="Plugged in, not charging" ;;
    *) details="On battery${time:+, $time left}" ;;
  esac
  sketchybar --set battery.details label="$details" --set "$NAME" popup.drawing=on
fi
