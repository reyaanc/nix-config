#!/bin/bash

source "$CONFIG_DIR/colors.sh"

# Sketchybar only starts a scroll on an update right after the item's script ran; spotify_scroll is that update.
case $SENDER in
  mouse.entered) sketchybar --set "$NAME" scroll_texts=on --trigger spotify_scroll; exit ;;
  mouse.exited) sketchybar --set "$NAME" scroll_texts=off; exit ;;
  spotify_scroll) exit ;;
esac

PLAYBACK=/tmp/sketchybar/spotify.playback

# Spotify posts no notification for seeks or for time passing, so between reads the bar extrapolates from the last one,
# asking Spotify again only every 30s to pick up a seek.
if [ "$SENDER" = routine ] && read -r read_at position duration < "$PLAYBACK" && (( $(date +%s) - read_at < 30 )); then
  sketchybar --animate linear 30 --set spotify.progress slider.percentage=$(( (($(date +%s) - read_at) * 1000 + position) * 100 / duration ))
  exit
fi

if [ "$SENDER" = "mouse.clicked" ]; then
  [ "$BUTTON" = right ] && command="next track" || command=playpause
  osascript -e "tell application \"Spotify\" to $command"
fi

status=$(osascript \
  -e 'if application "Spotify" is running then' \
  -e 'tell application "Spotify"' \
  -e 'if player state is not stopped then return (player state as text) & "|" & (player position * 1000 div 1) & "|" & (duration of current track) & "|" & (name of current track) & " — " & (artist of current track)' \
  -e 'end tell' \
  -e 'end if')

IFS='|' read -r state position duration track <<< "$status"
echo "$(date +%s) $position $duration" > "$PLAYBACK"
progress=$(( ${position:-0} * 100 / ${duration:-1} ))

case $state in
  playing) sketchybar --set spotify drawing=on update_freq=5 label.color=$SUBTEXT label="$track" --set spotify.icon drawing=on icon= icon.font.size=14 icon.color=$ACCENT --set spotify.progress slider.highlight_color=$ACCENT ;;
  paused) sketchybar --set spotify drawing=on update_freq=0 label.color=$DIM label="$track" --set spotify.icon drawing=on icon= icon.font.size=13 icon.color=$DIM --set spotify.progress slider.highlight_color=$DIM ;;
  *) sketchybar --set spotify drawing=off update_freq=0 --set spotify.icon drawing=off --set spotify.progress drawing=off; exit ;;
esac

sketchybar --set spotify.progress drawing=on slider.percentage="$progress"
