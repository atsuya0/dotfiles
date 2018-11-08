#!/usr/bin/bash

set -euC

killall -q polybar

while pgrep -u ${UID} -x polybar > /dev/null;do
  sleep 1
done

if [[ $# -eq 0 ]]; then
  MONITOR=$(type xrandr &> /dev/null \
    && xrandr --listactivemonitors | sed '1d;s/  */ /g' | cut -d' ' -f5 | tail -1)
else
  MONITOR=$1
fi
export MONITOR

polybar -r --config=${DOTFILES}/polybar/config bar1 &
