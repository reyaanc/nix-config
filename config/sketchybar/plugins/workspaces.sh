#!/bin/bash

# Events arrive in bursts (a window move fires several), so one landing mid-render only marks the bar dirty and the run in flight renders once more.
if [ -z "$WS_LOCKED" ]; then
  touch /tmp/sketchybar/workspaces.dirty
  while [ -e /tmp/sketchybar/workspaces.dirty ]; do
    WS_LOCKED=1 /usr/bin/lockf -s -k -t 0 /tmp/sketchybar/workspaces.lock "$0"
    [ $? = 75 ] && exit
  done
  exit
fi
rm -f /tmp/sketchybar/workspaces.dirty

source "$CONFIG_DIR/plugins/icon_map.sh"
source "$CONFIG_DIR/colors.sh"

all=$(aerospace list-windows --all --format '%{workspace-is-focused}|%{window-id}|%{workspace}|%{app-pid}|%{app-name}|%{window-title}') || exit 0
# The focused workspace can be read off one of its windows, saving a second aerospace round trip unless it is empty
re=$'\n''true\|[^|]*\|([^|]*)'
[[ $'\n'$all =~ $re ]] && focused=${BASH_REMATCH[1]} || focused=$(aerospace list-workspaces --focused)
windows=$([ -n "$all" ] && while IFS='|' read -r _ wid ws pid app title; do
  # herdr titles its Ghostty window "herdr · {workspace}", so it shares the Herdr app's icon
  [ "$app" = Ghostty ] && [[ $title == "herdr · "* ]] && app=Herdr
  echo "$wid|$ws|$pid|$app"
done <<< "$all" | awk -F'|' -v OFS='|' '
function add(  k, xy) {
  # One icon per app (and Firefox profile) per workspace, placed by its top-left window
  k = $2 OFS $4 OFS avatar[$3]
  if (!(k in x)) x[k] = y[k] = 1e9
  if ($1 in pos) {
    split(pos[$1], xy)
    if (xy[1] < x[k] || xy[1] == x[k] && xy[2] < y[k]) { x[k] = xy[1]; y[k] = xy[2] }
  }
}
BEGIN {
  while ((getline < "/tmp/sketchybar/positions") > 0) { pos[$1] = $2 OFS $3; size[$1] = $4 }
  while ((getline < "/tmp/sketchybar/firefox") > 0) avatar[$1] = $2
}
# Windows covering under 30% of their screen (popups, pickers, small floats) get no icon, unless the workspace has nothing bigger
size[$1] != "" && size[$1] < 30 {
  if (!($2 in biggest) || size[$1] > biggest[$2]) { biggest[$2] = size[$1]; small[$2] = $0 }
  next
}
{ shown[$2] = 1; add() }
END {
  for (ws in small) if (!(ws in shown)) { $0 = small[ws]; add() }
  for (k in x) print k, x[k], y[k]
}' | sort -t'|' -k1,1 -k4,4n -k5,5n -k2,2)
badges=$(cat /tmp/sketchybar/badges 2>/dev/null)
side=$(aerospace list-workspaces --all --format '%{workspace}|%{monitor-is-main}' | awk -F'|' '$2 == "false" { printf " %s ", $1 }')
# nf-fa-circle, nf-fa-square and nf-md-monitor, as bytes since bash 3.2 has no \u escapes
dot=$'\xef\x84\x91' square=$'\xef\x83\x88' monitor=$'\xf3\xb0\x8d\xb9'

args=() layout=
for sid in 1 2 3 4 5 6 7 8 9; do
  apps=() avatars=()
  while IFS='|' read -r ws app avatar _; do
    [ "$ws" = "$sid" ] || continue
    apps+=("$app") avatars+=("$avatar")
  done <<< "$windows"
  apps=("${apps[@]:0:8}")
  count=${#apps[@]}
  layout+="$count "

  if [ "$sid" = "$focused" ]; then
    args+=(--set "space.$sid" background.drawing=on icon.color=$ACCENT)
    highlight=on base=$FOREGROUND fade=45
  else
    args+=(--set "space.$sid" background.drawing=off icon.color=$DIM)
    highlight=off base=${DIM:4} fade=60
  fi

  if [ "$count" -gt 0 ]; then
    args+=(label.drawing=off)
  else
    args+=(label.drawing=on)
  fi

  if [[ $side == *" $sid "* ]]; then
    args+=(icon="$sid $monitor" icon.width=37)
    layout+="m"
  else
    args+=(icon="$sid" icon.width=21)
  fi

  args+=(--set "/space\.$sid\..*/" drawing=off)
  for i in "${!apps[@]}"; do
    __icon_map "${apps[$i]}"
    __brand_color "${apps[$i]}"
    mix tint "${brand:-$base}" "$base" $fade
    width=21
    [ $((i + 1)) = "$count" ] && width=23
    font="sketchybar-app-font:Regular:15.0"
    # The app font draws iPhone Mirroring as a hairline outline, so it borrows the bolder nf-md-cellphone
    [ "${apps[$i]}" = "iPhone Mirroring" ] && icon_result=$'\xf3\xb0\x84\x9c' font="$FONT:Bold:16.0" width=$((width - 9))
    # The app font has no Herdr glyph, so Herdr's own ram logo is drawn as an image, rendered once per tint
    logo=off
    if [ "${apps[$i]}" = Herdr ]; then
      png=/tmp/sketchybar/herdr-${tint:4}.png
      [ -f "$png" ] || sed "s/#303438/#${tint:4}/" "$CONFIG_DIR/icons/herdr.svg" | rsvg-convert -h 30 -o "$png"
      icon_result= logo=on
    fi
    # Thunderbird's bird-and-envelope glyph breaks up into noise at bar size
    [ "${apps[$i]}" = Thunderbird ] && icon_result=:mail:
    badge=off badge_color=$CRIT mark=$dot mark_y=5
    while IFS='|' read -r app label; do
      [ "$app" = "${apps[$i]}" ] || continue
      badge=on
      # A bare dot is unread activity with nothing aimed at you (Slack channels), so it stays quiet; counts are mentions and DMs.
      [ "$label" = "•" ] && badge_color=$SUBTEXT
    done <<< "$badges"
    __profile_color "${avatars[$i]}"
    # A Firefox window outside the default profile gets a square of its colour, bottom right so it can't pass for a badge
    [ $badge = off ] && [ -n "$profile" ] && badge=on badge_color=0xff$profile mark=$square mark_y=-6
    args+=(--set "space.$sid.$((i + 1))" drawing=on icon="$icon_result" icon.font="$font" icon.color=$tint icon.width=$width background.drawing=$highlight
      label="$mark" label.y_offset=$mark_y label.drawing=$badge label.color=$badge_color label.padding_left=$((12 - width)) label.padding_right=$((width - 12))
      icon.background.drawing=$logo)
    [ $logo = on ] && args+=(--set "space.$sid.$((i + 1))" icon.background.image="$png" icon.background.image.scale=0.5 icon.background.color=0x00000000)
  done
done

# Most triggers are focus changes that leave the bar as it was, and redrawing every icon is the slowest step
state="${args[*]}"
[ "$state" = "$(cat /tmp/sketchybar/workspaces.state 2>/dev/null)" ] && exit
# The first draw after a (re)load fills the bar sketchybarrc kept hidden, all at once and without animating in
if [ -e /tmp/sketchybar/workspaces.state ]; then
  sketchybar --animate tanh 3 "${args[@]}"
else
  sketchybar "${args[@]}" --bar hidden=off
fi
echo "$state" > /tmp/sketchybar/workspaces.state

# agenda.py fits its label to the room the spaces leave, which only changes with how many icons each one shows.
[ "$layout" = "$(cat /tmp/sketchybar/workspaces 2>/dev/null)" ] && exit
echo "$layout" > /tmp/sketchybar/workspaces
sketchybar --trigger workspaces_change
