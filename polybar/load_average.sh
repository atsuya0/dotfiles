#!/usr/bin/bash

function format() {
  echo "%{F$1}%{u$1}"
}


function main() {
  local icon=''
  local load_average=$(uptime \
    | sed -E 's/.*load average: ([0-9]\.[0-9][0-9]).*/\1/g')
  local cpus_num=$(grep 'processor' /proc/cpuinfo | wc -l)
  echo "$(format '#c0c5ce')${icon} ${load_average}/${cpus_num}"
}

main
