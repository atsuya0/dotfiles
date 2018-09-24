#!/usr/bin/bash

function format() {
  echo "%{F$1}%{u$1}"
}


function main() {
  local icon=''
  local memory=($(free -b | sed '/^Mem:/!d;s/  */ /g'))
  local Mi=$(( ${memory[2]} / $((1024 * 1024)) ))
  local rate=$(( ${memory[2]} * 100 / ${memory[1]} ))

  echo ${Mi}
  #[[ ${Mi#} -gt 4 ]] && echo ${Mi}
  #echo "$(format '#c0c5ce')${icon}  : ${rate}%"
}

main
