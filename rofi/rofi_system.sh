#!/usr/bin/env bash

set -euCo pipefail

declare -A list=(
  ['Logout']='i3-msg exit'
  ['Poweroff']='systemctl poweroff'
  ['Reboot']='systemctl reboot'
)

function print_keys() {
  echo "${!list[@]}" | sed 's/ /\n/g'
}

function main() {
  local yes='(yes)' no='(no)'

  [[ $# -eq 0 ]] \
    && { print_keys; return 0; }

  case ${2} in
    ${yes} )
      eval "${list[$1]}"
    ;;
    ${no} )
      print_keys
    ;;
    * )
      echo $1 ${no}
      echo $1 ${yes}
    ;;
  esac
}

main $@

#[[ $# -ne 0 ]] && eval "${list[$1]}" || echo "${!list[@]}" | sed 's/ /\n/g'
