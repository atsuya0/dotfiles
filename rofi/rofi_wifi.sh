#!/usr/bin/env bash

set -euCo pipefail

function main() {
  declare -A list=(
    ['home']='wlp4s0-184F3214892B-5G'
    ['school']='wlp4s0-SOFTBUNYA41-2_5'
  )

  [[ $# -ne 0 ]] \
    && sudo netctl start "${list[$1]}" \
    || echo "${!list[@]}" | sed 's/ /\n/g'
}

main $@
