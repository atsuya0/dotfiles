#!/usr/bin/env bash

set -euCo pipefail

function main() {
  type xrandr &> /dev/null || return

  local primary secondary
  primary=$(xrandr --listactivemonitors | sed '1d;s/  */ /g' | cut -d' ' -f5 | head -1)
  secondary=$(xrandr | grep ' connected' | cut -d' ' -f1 | grep -v ${primary})

  [[ $# -ne 0 ]] \
    && xrandr --output ${second} --left-of ${primary} --mode $1 \
    || xrandr | sed -n "/^${second}/,/^[^ ]/p" | sed '/^[^ ]/d;s/  */ /g' | cut -d' ' -f2
}

main $@
