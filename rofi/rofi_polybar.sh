#!/usr/bin/env bash

set -euCo pipefail

function main() {
  local -a monitors
  monitors=($(xrandr --listactivemonitors \
    | grep -o '[[:blank:]][[:alpha:]]\+[[:digit:]]' \
    | tr -d '[[:blank:]]'))

  local IFS=$'\n'

  [[ $# -ne 0 ]] \
    && $(find ${DOTFILES} -type f -name 'launch.sh') $1 &> /dev/null \
    || echo "${monitors[*]}"
}

main $@
