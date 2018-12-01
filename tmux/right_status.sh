#!/usr/bin/bash

set -euC

# 区切り文字
function sep() {
  [[ $# -lt 1 ]] && return 1
  format $1 ''
}

function value() {
  [[ $# -lt 2 ]] && return 1
  format $1 " $2 "
}

function format() {
  local -r black='#[fg=black,bg=blue]'
  local -r blue='#[fg=blue,bg=black]'
  local -r def='#[default]'

  [[ $# -lt 2 ]] && return 1

  [[ $1 == 'black' ]] \
    && echo "${black}$2${def}" && return 0
  [[ $1 == 'blue' ]] \
    && echo "${blue}$2${def}" && return 0
  echo "$1$2${def}"
}

# メモリ使用量
function memory() {
  local src
  src=$(free -h | sed '/^Mem:/!d;s/  */ /g' | cut -d' ' -f3)
  echo "$(sep 'blue')$(value 'black' ${src})"
}

# ロードアベレージ
function load_average() {
  local src cpus
  src=$(uptime | sed -E 's/.*load average: ([0-9]\.[0-9][0-9]).*/\1/g')
  cpus=$(grep 'processor' /proc/cpuinfo | wc -l)
  echo "$(sep 'black')$(value 'blue' ${src}/${cpus})"
}

# ネットワーク
function wlan() {
  local signal
  type iw &> /dev/null \
    && [[ $(iw dev wlp4s0 link) != 'Not connected.' ]] \
    && signal="-$(iw dev wlp4s0 link | grep signal | grep -o '[0-9]*')dBm"
  echo "$(sep 'blue')$(value 'black' ${signal:----})"
}

# 音量
function sound() {
  function get_volume() {
    local volume
    volume="$(pactl list sinks \
      | grep 'Volume' | grep -o '[0-9]*%' | head -1 | tr -d '%')"
    [[ ${volume} -gt 100 ]] && echo 100 || echo "${volume}"
  }

  function get_muted() {
    pactl list sinks \
      | grep 'Mute' | sed 's/[[:space:]]//g' | cut -d: -f2 | head -1
  }

  function to_blocks() {
    seq -f '%02g' -s '' 1 5 $1 | sed 's/.\{2\}/■/g'
  }

  function to_spaces() {
    seq -s '_' $1 5 100 | tr -d '[:digit:]'
  }

  function to_meters() {
    echo "[$(to_blocks $1)$(to_spaces $1)]"
  }

  type pactl &> /dev/null \
    || { echo "$(sep 'black')$(value 'blue' '×')" && return 1 ;}

  declare -A colors=( ['yes']='#[fg=colour237,bg=black]' ['no']='blue' )
  echo \
    "$(sep 'black')$(value ${colors[$(get_muted)]} $(to_meters $(get_volume)))" \
    | sed 's/_/ /g'
}

# 時刻
function hours_minutes() {
  echo "$(sep 'blue')$(value 'black' $(date +%H:%M))"
}

# バッテリー残量
function battery() {
  function online() {
    if [[ $(cat /sys/class/power_supply/ADP1/online) == '1' ]];then
      local -ar icons=('' '' '' '' '')
      local i
      i=$(expr $(date +%S) % ${#chars[@]})
      value 'blue' ${chars[${i}]}
    else
      echo ''
    fi
  }

  [[ -e '/sys/class/power_supply/BAT1' ]] \
    || { echo "$(sep 'black')$(online)" && return ;}

  local charge
  charge=$(< /sys/class/power_supply/BAT1/capacity)
  if [[ ${charge} -gt 79 ]];then
    local -r color='#[fg=#08d137,bg=black]'
  elif [[ ${charge} -gt 20 ]];then
    local -r color='#[fg=#509de0,bg=black]'
  else
    local -r color='#[fg=#f73525,bg=black]'
  fi
  echo "$(sep 'black')$(online)$(value ${color} ${charge}%)"
}

if [[ ${1:-long} == 'short' ]];then
  echo "$(memory)$(load_average) "
else
  echo "$(memory)$(load_average)$(wlan)$(sound)$(hours_minutes)$(battery) "
fi
