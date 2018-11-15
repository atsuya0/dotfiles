[[ -e ${_CD_FILE} ]] || export _CD_FILE=$(mktemp)

function __exec_tmux__() {
  type tmux &> /dev/null || return 1
  type fzf &> /dev/null || return 1
  [[ -n ${WINDOWID} ]] || return 1
  [[ $(ps -ho args ${PPID} | tr -s ' ' | cut -d' ' -f1) \
    =~ 'termite|alacritty' ]] || return 1

  typeset -r new='new-session'
  local id=$(
    echo "$(tmux list-sessions 2> /dev/null)\n${new}:" \
    | sed /^$/d | fzf --select-1 --reverse | cut -d: -f1
  )

  if [[ ${id} == ${new} ]]; then
    tmux -f "${DOTFILES}/tmux/tmux.conf" -2 new-session -s $1 && exit
  elif [[ -n ${id} ]]; then
    tmux attach-session -t "${id}"
  fi
}

[[ -z ${TMUX} ]] && () {
  type trash &> /dev/null && trash auto-delete
  __exec_tmux__ 'tmp' || return 1
} && return
