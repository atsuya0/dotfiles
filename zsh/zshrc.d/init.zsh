[[ -e ${_CD_FILE} ]] || export _CD_FILE=$(mktemp)

tmux list-session &> /dev/null || () {
  [[ -n ${commands[trash]} ]] && trash auto-delete
}

() { # tmux
  [[ -z ${WINDOWID} ]] && return 1
  [[ "$(ps hco cmd ${PPID})" =~ 'mlterm|alacritty' ]] || return 1
  [[ -n ${commands[tmux_management.sh]} ]] \
    && tmux_management.sh && exit
}
