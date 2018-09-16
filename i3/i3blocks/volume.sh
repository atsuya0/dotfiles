#!/usr/bin/zsh

type pactl &> /dev/null || return 1

# 動いているsinkの方の情報を取得する。 全て動いていない場合がある。
[[ -n $(pactl list sinks | grep 'RUNNING') ]] && cmd="grep -A 10 'RUNNING'" || cmd='tee'
[[ $(pactl list sinks | eval ${cmd} | grep 'Mute:' | cut -d' ' -f2) == 'no' ]] && color='#d0dcef' || color='#6e7177'
pactl list sinks | eval "${cmd}" | grep -o '[0-9]*%' | head -1 && echo -e "\n${color}"
