#!/usr/bin/env bash

set -euCo pipefail

function main() {
  type xrandr &> /dev/null || return

  local primary secondary
  primary=$(xrandr --listactivemonitors | grep -o '*[[:alpha:]]\+[[:digit:]]' | tr -d '*')
  secondary=$(xrandr | grep ' connected' | cut -d' ' -f1 | grep -v ${primary})

  [[ $# -ne 0 ]] \
    && xrandr --output ${second} --left-of ${primary} --mode $1 \
    || xrandr \
        | sed -n "/^HDMI1/,/^[^ ]/p" \
        | grep -o '[[:digit:]]\+x[[:digit:]]\+\(i\|[[:blank:]]\)' \
        | tr -d '[[:blank:]]'
}

main $@
