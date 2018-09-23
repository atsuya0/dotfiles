#!/usr/bin/bash

declare -A list=(
  ['home']='wlp4s0-184F3214892B-5G'
  ['school']='wlp4s0-SOFTBUNYA41-2_5'
)

[[ -n $1 ]] \
  && sudo netctl start "${list[$1]}" \
  || echo "${!list[@]}" | sed 's/ /\n/g'
