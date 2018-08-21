#!/usr/bin/bash

# 区切り文字
sep=''

# メモリ使用量
memory="#[fg=blue]${sep}#[fg=black,bg=blue] $(free -h | sed '/^Mem:/!d;s/  */ /g' | cut -d' ' -f3) #[default]"

# ロードアベレージ
la="#[fg=black,bg=blue]${sep}#[default]#[fg=blue,bg=black] $(uptime | sed -E 's/.*load average: ([0-9]\.[0-9][0-9]).*/\1/g')/$(cat /proc/cpuinfo | grep processor | wc -l) #[default]"

# ネットワーク
[[ $(iw dev wlp4s0 link) != 'Not connected.' ]] && signal="-$(iw dev wlp4s0 link | grep signal | grep -o '[0-9]*')dBm" || signal='---'
signal="#[fg=blue,bg=black]${sep}#[default]#[fg=black,bg=blue] ${signal} #[default]"

# 音量
if type pactl > /dev/null 2>&1;then
  [[ -n $(pactl list sinks | grep 'RUNNING') ]] && cmd="grep -A 10 'RUNNING'" || cmd='tee'
  [[ $(pactl list sinks | eval ${cmd} | grep 'Mute:' | cut -d' ' -f2) == 'no' ]] && volMeter='#[fg=blue,bg=black] ' || volMeter='#[fg=colour237,bg=black] '
  volume=$(expr $(pactl list sinks | eval ${cmd} | grep -o '[0-9]*%' | head -1 | sed 's/%//g') / 5)
  volMeter="${volMeter}["
  for i in $(seq 1 ${volume});do
    volMeter="${volMeter}■"
  done
  for i in $(seq ${volume} 20);do
    volMeter="${volMeter} "
  done
  volMeter="${volMeter}] "
else
  volMeter='#[fg=blue,bg=black] × #[default]'
fi
volMeter="#[fg=black,bg=blue]${sep}#[default]${volMeter}#[default]"

# 時刻
date="#[fg=blue,bg=black]${sep}#[fg=black,bg=blue] $(date +%H:%M) #[default]"

# バッテリー残量
batteryColor=#[fg=black,bg=blue]${sep}#[default]
if [[ $(cat /sys/class/power_supply/ADP1/online) == '1' ]];then
  declare -a char=('◜' '◝' '◟' '◞')
  i=$(expr $(date +%S) % 4)
  batteryColor="${batteryColor}#[fg=blue,bg=black] ${char[i]} #[default]"
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
  batteryColor="${batteryColor} ${battery}% #[default]"
fi

if [[ $1 == 'short' ]];then
  echo "${memory}${la}"
else
  echo "${memory}${la}${signal}${volMeter}${date}${batteryColor}"
fi
