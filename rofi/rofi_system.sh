#!/usr/bin/bash

declare -A list=(
  ['Logout']='i3-msg exit'
  ['Poweroff']='systemctl poweroff'
  ['Reboot']='systemctl reboot'
  ['Lock']='light-locker-command --lock'
)

function print_key() {
  echo "${!list[@]}" | sed 's/ /\n/g'
}

function main() {
  if [[ ${1##* } == 'yes' ]]; then
    eval "${list[${1%% *}]}"
  elif [[ ${1##* } == 'no' ]]; then
    print_key
  elif [[ -n $1 ]]; then
    echo -e "$1 / no\n$1 / yes"
  else
    print_key
  fi
}

main $@

#[[ -n $1 ]] && eval "${list[$1]}" || echo "${!list[@]}" | sed 's/ /\n/g'
