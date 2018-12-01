#!/usr/bin/bash

# unused

set -euC

function separate() {
  seq -s '-' $(expr $(tput cols) / 2) | tr -d '[:digit:]' | sed 's/.*/\n&\n/'
}

function format() {
  echo -e "\033[1;34m$1\033[0;49m"
}

function list_windows() {
  tmux list-windows -t $1 | cut -d' ' -f2 | nl
}

function capture_pane() {
  tmux capture-pane -e -J -t $1 -p
}

function echo_section() {
  [[ 3 -gt $# ]] && return 1
  separate
  format $1
  eval $2 $3
}

function main() {
  echo_section 'list_windows' list_windows $1
  echo_section 'capture_pane' capture_pane $1
}

main $1
