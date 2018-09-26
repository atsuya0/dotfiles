#!/usr/bin/bash

function main() {
  local monitors=$(xrandr --listactivemonitors | sed '1d;s/  */ /g' | cut -d' ' -f5)

  [[ -n $1 ]] \
    && $(find ${DOTFILES} -type f -name 'launch.sh') $1 &> /dev/null \
    || echo ${monitors} | sed 's/ /\n/g'
}

main $@
