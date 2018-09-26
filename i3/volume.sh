#!/usr/bin/bash

function volume() {
  pactl list sinks | grep 'Volume' | grep -o '[0-9]*%' | head -1
}

function toggle() {
  declare -A state=(
    ['yes']=1
    ['no']=0
  )
  local muted=$(pactl list sinks \
    | grep 'Mute' | sed 's/[[:space:]]//g' | cut -d: -f2 | head -1)
  echo ${state[${muted}]}
}

function main() {
  type pactl &> /dev/null || return 1

  local sinks='pactl list sinks short | cut -f1 | sed 1d'

  case $1 in
    'up' )
      pactl set-sink-volume 0 +5%
      eval ${sinks} | xargs -I{} pactl set-sink-volume {} $(volume)
    ;;
    'down' )
      pactl set-sink-volume 0 -5%
      eval ${sinks} | xargs -I{} pactl set-sink-volume {} $(volume)
    ;;
    'mute' )
      pactl set-sink-mute 0 toggle
      eval ${sinks} | xargs -I{} pactl set-sink-mute {} $(toggle)
    ;;
  esac

  pkill -SIGRTMIN+1 i3blocks
  # tmux refresh -S
}

main $@
