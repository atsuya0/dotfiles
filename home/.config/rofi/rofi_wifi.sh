#!/usr/bin/env bash

set -euCo pipefail

function main() {
  local -Ar SSIDs=(
    ['home']='wlp4s0-184F3214892B-5G'
    ['school']='wlp4s0-SOFTBUNYA41-2_5'
  )

  local -r IFS=$'\n'

  [[ $# -ne 0 ]] \
    && sudo netctl start ${SSIDs[$1]} \
    || echo "${!SSIDs[*]}"
}

main $@
