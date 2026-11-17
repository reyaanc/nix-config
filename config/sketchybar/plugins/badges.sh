#!/bin/bash

badges=$(aerospace list-apps --format '%{app-name}' | while IFS= read -r app; do
  # Ghostty's badge is app-wide and would mark every one of its windows
  [ "$app" = Ghostty ] && continue
  label=$(lsappinfo info -only StatusLabel "$app" | sed -n 's/.*"label"="\(.*\)".*/\1/p')
  [ -n "$label" ] && echo "$app|$label"
done)

[ "$badges" = "$(cat /tmp/sketchybar/badges 2>/dev/null)" ] && exit 0
echo "$badges" > /tmp/sketchybar/badges
sketchybar --trigger badges_change
