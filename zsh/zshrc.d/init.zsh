[[ -e ${_CD_FILE} ]] || export _CD_FILE=$(mktemp)

tmux list-session &> /dev/null || () {
  type trash &> /dev/null && trash auto-delete
}

() { # tmux
  [[ -z ${WINDOWID} ]] && return 1
  [[ "$(ps hco cmd ${PPID})" =~ 'mlterm|alacritty' ]] || return 1
  type tmux_management.sh &> /dev/null \
    && tmux_management.sh && exit
}
