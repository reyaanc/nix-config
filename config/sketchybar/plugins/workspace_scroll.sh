#!/bin/bash

[ "$SENDER" = "mouse.scrolled" ] || exit 0

direction=next
[[ $SCROLL_DELTA == -* ]] && direction=prev

/usr/bin/lockf -s -t 0 /tmp/sketchybar/workspace_scroll.lock /bin/bash -c \
  "aerospace list-workspaces --monitor focused --empty no | aerospace workspace --stdin --wrap-around $direction; sleep 0.4"
