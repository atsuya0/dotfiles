#!/usr/bin/env bash

set -euCo pipefail

# $1: essid, $2: signal
function print_wlan() {
  source "$(dirname $0)/format.sh"

  local icon=''
  echo "$(fg 'blue')${icon} $(text 'fg')$(underline 'blue')${1:----} : -${2:-0}dBm"
}

function main() {
  type iw &> /dev/null || return
  [[ $(iw dev wlp4s0 link | wc -l) -lt 1 ]] \
    && print_wlan && return

  local signal essid
  signal=$(iw dev wlp4s0 link | grep signal | grep -o '[0-9]*')
  essid=$(iw dev wlp4s0 link | sed '/SSID/!d;s/ //g;s/[^:]*://')
  print_wlan ${essid} ${signal}
}

main
