#!/usr/bin/bash

set -eC

function list_other_session_name() {
  tmux list-session -F "#{session_id}:#{session_name}" \
    | cut -c2- \
    | grep -v "${TMUX##*,}:" \
    | cut -d: -f2
}

function choice() {
  fzf --reverse --exit-0 --select-1 \
    --preview="test -f ${DOTFILES}/tmux/preview.sh \
      && ${DOTFILES}/tmux/preview.sh {}" \
    --preview-window="right:80%"
}

function new_session() {
  local prefix
  [[ -f "${DOTFILES}/tmux/tmux.conf" ]] && prefix="${DOTFILES}/tmux/"
  tmux -f "${prefix:-${HOME}/.}tmux.conf" -2 new-session -s $1
}

function start_tmux() {
  typeset -r new="new-session:$(date +%s | cut -c6-)"
  local name=$(
    tmux ls -F "#{session_name}" | sed "$(echo '$a') ${new}" | choice
  )

  if [[ ${name} == ${new} ]]; then
    new_session "tmp_$(date +%s | cut -c6-)"
  elif [[ -n ${name} ]]; then
    tmux attach-session -t ${name}
  fi
}

function main() {
  type tmux &> /dev/null || return 1
  type fzf &> /dev/null || return 1

  # No tmux server.
  tmux list-session &> /dev/null || { new_session 'first' && return ;}

  # Attached session.
  [[ -n ${TMUX} ]] \
    && list_other_session_name | choice | xargs -I{} tmux switch-client -t {} \
    || start_tmux
}

main
