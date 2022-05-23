#!/usr/bin/env bash

set -euCo pipefail

function radio_strength() {
  cat /proc/net/wireless | tail -1 | tr -s ' ' | cut -d' ' -f4 | sed 's/\./dBm/'
}

function ssid() {
  { echo 'status'; echo 'quit'; } | wpa_cli -i ${wlan} | grep '^ssid=' | cut -d= -f2
}

function main() {
  which wpa_cli &> /dev/null || return 1

  local -r wlan=$(networkctl 2> /dev/null | grep wlan | tr -s ' ' | cut -d' ' -f3)
  [[ -z $(ip link show up dev ${wlan}) ]] && return 1

  echo "$(ssid) : $(radio_strength)"
}

main
