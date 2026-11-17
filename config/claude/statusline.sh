#!/usr/bin/env bash
input=$(cat)

cwd=$(jq -r '.workspace.current_dir // .cwd' <<<"$input")
model=$(jq -r '.model.display_name' <<<"$input")
ctx_pct=$(jq -r '.context_window.used_percentage // empty' <<<"$input")
branch=$(git -C "$cwd" -c core.hooksPath=/dev/null symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)

RESET=$'\033[0m'
FG=$'\033[1;38;2;197;201;197m'
DIM=$'\033[38;2;115;124;115m'
BLUE=$'\033[38;2;139;164;176m'
PURPLE=$'\033[38;2;162;146;163m'
CYAN=$'\033[38;2;142;164;162m'
YELLOW=$'\033[38;2;196;178;138m'
RED=$'\033[38;2;196;116;110m'

build_bar() {
  local pct=$1 filled=$(( $1 * 8 / 100 )) color result="" i
  if   [ "$pct" -ge 75 ]; then color=$RED
  elif [ "$pct" -ge 50 ]; then color=$YELLOW
  else                          color=$CYAN
  fi
  for i in 1 2 3 4 5 6 7 8; do
    if [ "$i" -le "$filled" ]; then result+="${color}▊"
    else                             result+="${DIM}▊"
    fi
  done
  printf '%s%s' "$result" "$RESET"
}

dir=$cwd
[[ $cwd == /*/*/* ]] && parent=${cwd%/*} && dir="${parent##*/}/${cwd##*/}"
[ -n "$ctx_pct" ] && pct=$(printf '%.0f' "$ctx_pct")
plain="${model}${pct:+  ctx ${pct}%}${branch:+  ${branch}}  ${dir}"

out="${BLUE}${model}${RESET}"
if [ -n "$pct" ]; then
  out+="  ${DIM}ctx${RESET} "
  # 9 = the 8-cell bar plus its space, 2 = Claude Code's statusline padding
  [ $(( ${#plain} + 9 + 2 )) -le "${COLUMNS:-80}" ] && out+="$(build_bar "$pct") "
  out+="${FG}${pct}%${RESET}"
fi
[ -n "$branch" ] && out+="  ${PURPLE}${branch}${RESET}"
out+="  ${FG}${dir}${RESET}"

printf '%s' "$out"
