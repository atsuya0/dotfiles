#!/usr/bin/bash

declare -A list=(
  ['Lock']='dm-tool lock'
  ['Logout']='i3-msg exit'
  ['Poweroff']='systemctl poweroff'
  ['Reboot']='systemctl reboot'
)

if [[ ${1##* } == 'yes' ]]; then
  eval "${list[${1%% *}]}"
elif [[ ${1##* } == 'no' ]]; then
  echo "${!list[@]}" | sed 's/ /\n/g'
elif [[ -n $1 ]]; then
  echo "$1 / no"
  echo "$1 / yes"
else
  echo "${!list[@]}" | sed 's/ /\n/g'
fi

#[[ -n $1 ]] && eval "${list[$1]}" || echo "${!list[@]}" | sed 's/ /\n/g'
