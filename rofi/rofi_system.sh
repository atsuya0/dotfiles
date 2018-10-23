#!/usr/bin/bash

declare -A list=(
  ['Logout']='i3-msg exit'
  ['Poweroff']='systemctl poweroff'
  ['Reboot']='systemctl reboot'
)

function print_key() {
  echo "${!list[@]}" | sed 's/ /\n/g'
}

function main() {
  local y='(yes)' n='(no)'

  if [[ $2 == $y ]]; then
    eval "${list[$1]}"
  elif [[ $2 == $n ]]; then
    print_key
  elif [[ -n $1 ]]; then
    echo $1 $n
    echo $1 $y
  else
    print_key
  fi
}

main $@

#[[ -n $1 ]] && eval "${list[$1]}" || echo "${!list[@]}" | sed 's/ /\n/g'
