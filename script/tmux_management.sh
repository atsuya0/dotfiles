#!/usr/bin/env bash

set -eCo pipefail

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

  fzf --reverse --exit-0 \
    --preview="echo -e '$(title 'list_windows')' && ${list_windows} \
                && echo -e '$(title 'capture_pane')' && ${capture_pane}" \
    --preview-window='right:80%'

  return 0
}

function new_session() {
  [[ -f "${DOTFILES}/tmux/tmux.conf" ]] \
    && local prefix="${DOTFILES}/tmux/"
  tmux -f "${prefix:-${HOME}/.}tmux.conf" -2 new-session -s $1
}

function start_tmux() {
  function not_choose() {
    local input
    read -sp 'new-session [y/n]' input
    [[ ${input} == 'y' ]] \
      && new_session "tmp_$(date +%s | cut -c6-)"
  }

  local session_name
  session_name=$(tmux ls -F '#{session_name}' | choose)
  [[ -n ${session_name} ]] \
    && tmux attach-session -t ${session_name} \
    || not_choose
}

function main() {
  type tmux &> /dev/null || { echo 'Tmux is required.'; return 1; }
  type fzf &> /dev/null || { echo 'Fzf is required.';  return 1; }

  # No tmux server.
  tmux list-session &> /dev/null || { new_session 'zz'; return; }

  # Attached session.
  [[ -n ${TMUX} ]] \
    && ( list_other_session_name \
          | choose | xargs -I{} tmux switch-client -t {}; return 0 ) \
    || start_tmux
}

main
