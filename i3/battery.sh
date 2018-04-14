#!/usr/bin/zsh

local char=('◜' '◝' '◞' '◟')
[[ $(cat /sys/class/power_supply/ADP1/online) = "1" ]] && echo -n "${char[$(expr $(expr $(date +%S) % 4) + 1)]} "

local battery=$([[ -e /sys/class/power_supply/BAT1 ]] && cat /sys/class/power_supply/BAT1/capacity)

local color='#439ad3'
[[ -n ${battery} ]] && { \
  if [[ ${battery} -gt 79 ]];then
    color='#08d137'
  elif [[ ${battery} -lt 21 ]];then
    color='#f73525'
  fi
  echo "${battery}% "
} || echo

echo -e "\n${color}"
