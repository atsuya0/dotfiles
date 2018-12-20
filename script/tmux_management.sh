#!/usr/bin/env bash

set -eCo pipefail

function list_other_session_name() {
  tmux list-session -F '#{session_id}:#{session_name}' \
    | cut -c2- \
    | grep -v "${TMUX##*,}:" \
    | cut -d: -f2
}

function choice() {
  local -r separate="seq -s '-' $(expr $(tput cols) / 2) | tr -d '[:digit:]' | sed 's/.*/\n&\n/'"
  local -r list_window_title="echo -e \"\033[1;34mlist-windows\033[0;49m\""
  local -r list_windows='tmux list-windows -t {} | cut -d' ' -f2 | nl'
  local -r capture_pane_title="echo -e \"\033[1;34mcapture_pane\033[0;49m\""
  local -r capture_pane='tmux capture-pane -e -J -t {} -p'

  fzf --reverse --exit-0 --select-1 \
    --preview="${separate};${list_window_title};${list_windows}; \
      ${separate};${capture_pane_title};${capture_pane}" \
    --preview-window='right:80%'
}

function new_session() {
  local prefix
  [[ -f "${DOTFILES}/tmux/tmux.conf" ]] && prefix="${DOTFILES}/tmux/"
  tmux -f "${prefix:-${HOME}/.}tmux.conf" -2 new-session -s $1
}

function start_tmux() {
  local -r new='<new-session>'
  local session_name
  session_name=$(
    tmux ls -F '#{session_name}' | sed "$(echo '$a') ${new}" | choice
  )

  if [[ ${session_name} == ${new} ]]; then
    new_session "tmp_$(date +%s | cut -c6-)"
  elif [[ -n ${session_name} ]]; then
    tmux attach-session -t ${session_name}
  fi
}

function main() {
  type tmux &> /dev/null || { echo 'Tmux is required.'; return 1; }
  type fzf &> /dev/null || { echo 'Fzf is required.';  return 1; }

  # No tmux server.
  tmux list-session &> /dev/null || { new_session 'zz'; return; }

  # Attached session.
  [[ -n ${TMUX} ]] \
    && ( list_other_session_name \
          | choice | xargs -I{} tmux switch-client -t {}; return 0 ) \
    || start_tmux
}

main
