#!/usr/bin/bash

# 区切り文字
sep=''
# 色
black='#[fg=black,bg=blue]'
blue='#[fg=blue,bg=black]'
def='#[default]'

# メモリ使用量
memory_cmd=$(free -h | sed '/^Mem:/!d;s/  */ /g' | cut -d' ' -f3)
memory="${blue}${sep}${black} ${memory_cmd} ${def}"

# ロードアベレージ
la_cmd=$(uptime | sed -E 's/.*load average: ([0-9]\.[0-9][0-9]).*/\1/g')
cpu_cmd=$(grep 'processor' /proc/cpuinfo | wc -l)
la="${black}${sep}${def}${blue} ${la_cmd}/${cpu_cmd} ${def}"

# ネットワーク
[[ $(iw dev wlp4s0 link) != 'Not connected.' ]] \
  && signal="-$(iw dev wlp4s0 link | grep signal | grep -o '[0-9]*')dBm" \
  || signal='---'
signal="${blue}${sep}${def}${black} ${signal} ${def}"

# 音量
if type pactl &> /dev/null;then
  [[ -n $(pactl list sinks | grep 'RUNNING') ]] \
    && cmd="grep -A 10 'RUNNING'" \
    || cmd='tee'
  mute=$(pactl list sinks | eval ${cmd} | grep 'Mute:' | cut -d' ' -f2)
  [[ ${mute} == 'no' ]] \
    && volMeter="${blue} " \
    || volMeter='#[fg=colour237,bg=black] '
  volume=$(
    pactl list sinks \
    | eval ${cmd} \
    | grep -o '[0-9]*%' \
    | head -1 \
    | sed 's/%//g')
  blocks=$(seq -f '%02g' -s '' 1 5 ${volume} | sed 's/.\{2\}/■/g')
  # spaces=$(seq -f '%02g' -s '' ${volume} 5 95 | sed 's/.\{2\}/ /g')
  spaces=$(seq -s ' ' ${volume} 5 100 | tr -d '[:digit:]')
  volMeter="${volMeter}[${blocks}${spaces}] "
else
  volMeter="${blue} × ${def}"
fi
volMeter="${black}${sep}${def}${volMeter}${def}"

# 時刻
date="${blue}${sep}${black} $(date +%H:%M) ${def}"

# バッテリー残量
batteryColor=${black}${sep}${def}
if [[ $(cat /sys/class/power_supply/ADP1/online) == '1' ]];then
  declare -a char=('◜' '◝' '◟' '◞')
  i=$(expr $(date +%S) % 4)
  batteryColor="${batteryColor}${blue} ${char[i]} ${def}"
fi
if [[ -e '/sys/class/power_supply/BAT1' ]];then
  battery=$(cat /sys/class/power_supply/BAT1/capacity)
  if [[ ${battery} -gt 79 ]];then
    batteryColor="${batteryColor}#[fg=#08d137,bg=black]"
  elif [[ ${battery} -gt 20 ]];then
    batteryColor="${batteryColor}#[fg=#509de0,bg=black]"
  else
    batteryColor="${batteryColor}#[fg=#f73525,bg=black]"
  fi
  batteryColor="${batteryColor} ${battery}% ${def}"
fi

if [[ $1 == 'short' ]];then
  echo "${memory}${la}"
else
  echo "${memory}${la}${signal}${volMeter}${date}${batteryColor}"
fi
