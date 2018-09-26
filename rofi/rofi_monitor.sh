#!/usr/bin/bash

type xrandr &> /dev/null || return

primary=$(xrandr --listactivemonitors | sed '1d;s/  */ /g' | cut -d' ' -f5 | head -1)
second=$(xrandr | grep ' connected' | cut -d' ' -f1 | grep -v ${primary})

[[ -n $1 ]] \
  && xrandr --output ${second} --left-of ${primary} --mode $1 \
  || xrandr | sed -n "/^${second}/,/^[^ ]/p" | sed '/^[^ ]/d;s/  */ /g' | cut -d' ' -f2
