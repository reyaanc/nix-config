#!/bin/bash

if [ -n "$MODE" ] && [ "$MODE" != main ]; then
  sketchybar --set "$NAME" drawing=on
else
  sketchybar --set "$NAME" drawing=off
fi
