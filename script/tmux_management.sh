#!/usr/bin/env bash

set -euCo pipefail

function list_other_session_name() {
  tmux list-session -F '#{session_id}:#{session_name}' \
    | cut -c2- \
    | grep -v "${TMUX##*,}:" \
    | cut -d: -f2
}

function choose() {
  function title() {
    echo "\n[ \033[1;34m$1\033[0;49m ]\n"
  }
  local -r list_windows="tmux list-windows -t {} | cut -d' ' -f1-2"
  local -r capture_pane='tmux capture-pane -e -J -t {} -p'

  fzf --reverse --exit-0 $@ \
    --preview="echo -e '$(title 'list_windows')' && ${list_windows} \
                && echo -e '$(title 'capture_pane')' && ${capture_pane}" \
    --preview-window='right:80%'

  return 0
}

function create_session() {
  [[ -f "${DOTFILES}/tmux/tmux.conf" ]] \
    && local prefix="${DOTFILES}/tmux/"
  tmux -f "${prefix:-${HOME}/.}tmux.conf" -2 new-session -s $1
}

function attach_session() {
  function not_choose() {
    local input
    read -sp 'new-session [y/n]' input
    [[ ${input} == 'y' ]] \
      && create_session "tmp_$(date +%s | cut -c6-)"
  }

  local session_name
  session_name=$(tmux ls -F '#{session_name}' | choose)
  [[ -n ${session_name} ]] \
    && tmux attach-session -t ${session_name} \
    || not_choose
}

function new() {
  # No tmux server.
  tmux list-session &> /dev/null || { create_session 'zz'; return; }

  if [[ -n ${TMUX:-} ]]; then # Attached session.
    list_other_session_name \
      | choose -1 \
      | xargs -I{} tmux switch-client -t {}
  else
    attach_session
  fi
}

function kill() {
  # No tmux server.
  tmux list-session &> /dev/null || return 1

  if [[ -n ${TMUX:-} ]]; then # Attached session.
    list_other_session_name | choose | xargs -p tmux kill-session -t
  else
    tmux ls -F '#{session_name}' | choose | xargs -p tmux kill-session -t
  fi
}

function main() {
  which tmux &> /dev/null || { echo 'tmux is required.'; return 1; }
  which fzf &> /dev/null || { echo 'fzf is required.';  return 1; }

  case ${1:-new} in
    'new' )
      new
    ;;
    'kill' )
      kill
    ;;
  esac
}

main $@
