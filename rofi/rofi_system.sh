#!/usr/bin/env bash

set -euCo pipefail

declare -rA menu=(
  ['Logout']='i3-msg exit'
  ['Poweroff']='systemctl poweroff'
  ['Reboot']='systemctl reboot'
)

function print_keys() {
  echo "${!menu[@]}" | sed 's/ /\n/g'
}

function main() {
  local yes='(yes)' no='(no)'

  [[ $# -eq 0 ]] \
    && { print_keys; return 0; }

  case ${2} in
    ${yes} )
      eval "${menu[$1]}"
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

#[[ $# -ne 0 ]] && eval "${menu[$1]}" || echo "${!menu[@]}" | sed 's/ /\n/g'
