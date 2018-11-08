#!/usr/bin/bash

set -euC

function get_volume() {
  local volume
  volume="$(pactl list sinks \
    | grep 'Volume' | grep -o '[0-9]*%' | head -1 | tr -d '%')"
  [[ ${volume} -gt 100 ]] && echo 100 || echo "${volume}"
}

function get_muted() {
  pactl list sinks \
    | grep 'Mute' | sed 's/[[:space:]]//g' | cut -d: -f2 | head -1
}

function to_blocks() {
  seq -f '%02g' -s '' 1 5 $1 | sed 's/.\{2\}/■/g'
}

function to_spaces() {
  seq -s ' ' $1 5 100 | tr -d '[:digit:]'
}

function to_meters() {
  echo "[$(to_blocks $1)$(to_spaces $1)]"
}

function main() {
  type pactl &> /dev/null || return 1

  declare -A colors=( ['yes']='#434447' ['no']='#8fa1b3' )
  echo -e "$(to_meters $(get_volume))\n\n${colors[$(get_muted)]}"
}

main
