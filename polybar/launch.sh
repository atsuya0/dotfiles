#!/usr/bin/bash

killall -q polybar

while pgrep -u ${UID} -x polybar > /dev/null;do
  sleep 1
done

if [[ $# -eq 0 ]]; then
  export MONITOR=$(type xrandr &> /dev/null \
    && xrandr --listactivemonitors | sed '1d;s/  */ /g' | cut -d' ' -f5 | tail -1)
else
  export MONITOR=$1
fi

polybar -r --config=${DOTFILES}/polybar/config bar1 &
