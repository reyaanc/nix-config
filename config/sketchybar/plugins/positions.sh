#!/bin/bash

positions=$(aerospace list-windows --all --format '%{window-id}|%{workspace-is-visible}' | awk -F'|' -v OFS='|' -v helper="$CONFIG_DIR/helpers/window_positions" '
BEGIN {
  while ((getline < "/tmp/sketchybar/positions") > 0) seen[$1] = $2 OFS $3 OFS $4
  while ((helper | getline) > 0) { live[$1] = $2 OFS $3 OFS $4; at[$1] = $2 OFS $3 }
}
{ id[NR] = $1; visible[$1] = $2 == "true"; if (!visible[$1]) parked[at[$1]] = 1 }
END {
  for (i = 1; i <= NR; i++) {
    w = id[i]
    # Hidden workspaces are parked in a screen corner, so their windows keep the position last seen while visible
    if (visible[w] && live[w] != "" && !(at[w] in parked)) seen[w] = live[w]
    if (w in seen) print w, seen[w]
  }
}')

[ "$positions" = "$(cat /tmp/sketchybar/positions 2>/dev/null)" ] && exit 0
echo "$positions" > /tmp/sketchybar/positions
sketchybar --trigger positions_change
