#!/usr/bin/bash

function format() {
  echo "%{F$1}%{u$1}"
}

function print_battery() {
  local on=''
  local off=''
  [[ $(cat /sys/class/power_supply/ADP1/online) == '1' ]] \
    && echo "$(format $1)${on} $2%" \
    || echo "$(format $1)${off} $2%"
}

function main() {
  battery=$([[ -e /sys/class/power_supply/BAT1 ]] && cat /sys/class/power_supply/BAT1/capacity)
  [[ -z ${battery} ]] && echo "$(format '#c0c5ce') No Battery" && return

  if [[ ${battery} -gt 79 ]];then
    print_battery '#08d137' ${battery}
  elif [[ ${battery} -lt 21 ]];then
    print_battery '#f73525' ${battery}
  else
    print_battery '#d0dcef' ${battery}
  fi
}

main
