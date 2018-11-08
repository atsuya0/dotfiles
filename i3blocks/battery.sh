#!/usr/bin/bash

set -euC

# args(1: icon, 2: data, 3: color)
function print_battery() {
  [[ "$(cat /sys/class/power_supply/ADP1/online)" == '1' ]] \
    && local online=''

  [[ $# -gt 2 ]] \
    && echo -e "${online:-$1} $2 \n\n$3" \
    || echo -e "${online:----} "
}

function main() {
  local battery \
    high=('#08d137' '' 79) \
    middle=('#8fa1b3' '') \
    low=('#f73525' '' 21)
  battery="$([[ -e /sys/class/power_supply/BAT1 ]] && cat /sys/class/power_supply/BAT1/capacity)"

  [[ -z ${battery} ]] && { print_battery ; return ;}

  if [[ ${battery} -gt ${high[2]} ]];then
    print_battery "${high[1]}" "${battery}%" "${high[0]}"
  elif [[ ${battery} -lt ${low[2]} ]];then
    print_battery "${low[1]}" "${battery}%" "${low[0]}"
  else
    print_battery "${middle[1]}" "${battery}%" "${middle[0]}"
  fi
}

main
