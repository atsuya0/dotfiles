#!/usr/bin/env bash

set -euCo pipefail

function print_sep() {
  [[ $# -lt 1 ]] && return 1
  print_value --color-name $1 --string ''
}

function print_value() {
  [[ $# -lt 2 ]] && return 1

  local -rA colors=(
    ['black']='#[fg=black,bg=blue]'
    ['blue']='#[fg=blue,bg=black]'
    ['default']='#[default]'
  )

  for option in $@; do
    case ${option} in
      '-n'|'--color-name' )
        [[ -z $2 || $2 =~ ^-+ ]] && return 1
        local color=${colors[$2]}
        shift 2
      ;;
      '-s'|'--string' )
        [[ -z $2 ]] && return 1
        local string=$2
        shift 2
      ;;
    esac
  done

  echo "${color} ${string}${colors['default']}"
}

function format_value() {
  [[ $# -lt 2 ]] && return 1
  # $1数値か

  [[ $(( $1 % 2 )) == 0 ]] \
    && echo -n $(print_sep 'blue')$(print_value -n 'black' -s "$2") \
    || echo -n $(print_sep 'black')$(print_value -n 'blue' -s "$2")
}

# メモリ使用量
function memory() {
  free -h | sed '/^Mem:/!d;s/  */ /g' | cut -d' ' -f3
}

# ロードアベレージ
function load_average() {
  local src cpus
  src=$(uptime | sed -E 's/.*load average: ([0-9]\.[0-9][0-9]).*/\1/g')
  cpus=$(grep 'processor' /proc/cpuinfo | wc -l)
  echo ${src}/${cpus}
}

function main() {
  [[ ${OSTYPE} != 'linux-gnu' ]] && return 1

  local -ra values=($(memory) $(load_average))
  local i=0
  for value in "${values[@]}"; do
    format_value ${i} "${value}" && let ++i
  done
  echo '  '
}

main ${1:-long}
