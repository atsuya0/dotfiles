#!/usr/bin/env bash

set -euCo pipefail

function main() {
  source "$(dirname $0)/format.sh"

  local icon=''
  local load_average cpus_num
  load_average=$(uptime \
    | sed -E 's/.*load average: ([0-9]\.[0-9][0-9]).*/\1/g')
  cpus_num=$(grep 'processor' /proc/cpuinfo | wc -l)

  echo "$(fg 'blue')${icon} $(text 'fg')$(underline 'blue')${load_average} / ${cpus_num}"
}

main
