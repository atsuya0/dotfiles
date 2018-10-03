#!/usr/bin/bash


function main() {
  type pactl &> /dev/null || return 1

  local volume=$(pactl list sinks \
    | grep 'Volume' | grep -o '[0-9]*%' | head -1 | tr -d '%')
  local muted=$(pactl list sinks \
    | grep 'Mute' | sed 's/[[:space:]]//g' | cut -d: -f2 | head -1)
  local blocks=$(seq -f '%02g' -s '' 1 5 ${volume} | sed 's/.\{2\}/■/g')
  local spaces=$(seq -s ' ' ${volume} 5 100 | tr -d '[:digit:]')

  [[ ${muted} == 'no' ]] \
    && local color='#8fa1b3' \
    || local color='#434447'

  echo -e "[${blocks}${spaces}]\n\n${color}"
}

main
