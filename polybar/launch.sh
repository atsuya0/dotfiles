#!/usr/bin/bash

killall -q polybar

while pgrep -u ${UID} -x polybar > /dev/null;do
  sleep 1
done

polybar -r --config=${DOTFILES}/polybar/config bar1 &
