#!/usr/bin/bash

# args(1: icon, 2: data, 3: color)
function print() {
  [[ $(cat /sys/class/power_supply/ADP1/online) == '1' ]] \
    && local online=''

  [[ $# -gt 2 ]] \
    && echo -e "${online:-$1} $2 \n\n$3" \
    || echo -e "${online:----} "
}

function main() {
  local high=('#08d137' '' 79) middle=('#8fa1b3' '') low=('#f73525' '' 21)

  local battery=$([[ -e /sys/class/power_supply/BAT1 ]] && cat /sys/class/power_supply/BAT1/capacity)
  [[ -z ${battery} ]] && { print ; return ;}

  if [[ ${battery} -gt ${high[2]} ]];then
    print ${high[1]} "${battery}%" ${high[0]}
  elif [[ ${battery} -lt ${low[2]} ]];then
    print ${low[1]} "${battery}%" ${low[0]}
  else
    print ${middle[1]} "${battery}%" ${middle[0]}
  fi
}

main
