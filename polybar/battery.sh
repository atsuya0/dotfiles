#!/usr/bin/env bash

set -euCo pipefail

function print_battery() {
  source "$(dirname $0)/format.sh"

  local on=''
  local off=''
  [[ $(cat /sys/class/power_supply/ADP1/online) == '1' ]] \
    && echo "$(fg $1)${on} $2%" \
    || echo "$(fg $1)${off} $2%"
}

function main() {
  local battery
  battery=$([[ -e /sys/class/power_supply/BAT1 ]] && cat /sys/class/power_supply/BAT1/capacity)
  [[ -z ${battery} ]] && echo && return

  if [[ ${battery} -gt 79 ]];then
    print_battery 'green' ${battery}
  elif [[ ${battery} -lt 21 ]];then
    print_battery 'red' ${battery}
  else
    print_battery 'blue' ${battery}
  fi
}

main
