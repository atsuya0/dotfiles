#!/usr/bin/bash

set -eu

function main() {
  source "$(dirname $0)/format.sh"

  local icon=''
  local load_average=$(uptime \
    | sed -E 's/.*load average: ([0-9]\.[0-9][0-9]).*/\1/g')
  local cpus_num=$(grep 'processor' /proc/cpuinfo | wc -l)

  echo "$(fg 'blue')${icon} $(text 'fg')$(underline 'blue')${load_average} / ${cpus_num}"
}

main
