#!/usr/bin/bash

type pactl &> /dev/null || return 1

function main() {
  local volume=$(pactl list sinks \
    | grep 'Volume' | grep -o '[0-9]*%' | head -1)
  local muted=$(pactl list sinks \
    | grep 'Mute' | sed 's/[[:space:]]//g' | cut -d: -f2 | head -1)
  [[ ${muted} == 'no' ]] \
    && echo ${volume} \
    || echo -e "${volume}\n\n#6e7177"
}

main
