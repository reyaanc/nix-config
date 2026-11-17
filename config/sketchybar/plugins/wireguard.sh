#!/bin/bash

source "$CONFIG_DIR/colors.sh"

if scutil --nc list | grep -m1 com.wireguard.macos | grep -q '(Connected)'; then
  sketchybar --set "$NAME" icon.color=$ACCENT
else
  sketchybar --set "$NAME" icon.color=$MUTED
fi
