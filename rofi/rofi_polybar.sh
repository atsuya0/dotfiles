#!/usr/bin/env bash

set -euCo pipefail

function main() {
  local monitors
  monitors=$(xrandr --listactivemonitors | sed '1d;s/  */ /g' | cut -d' ' -f5)

  [[ $# -ne 0 ]] \
    && $(find ${DOTFILES} -type f -name 'launch.sh') $1 &> /dev/null \
    || echo ${monitors} | sed 's/ /\n/g'
}

main $@
