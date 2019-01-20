[[ -e ${_CD_FILE} ]] || export _CD_FILE=$(mktemp -p /tmp cdh_XXXXXX.tmp)

tmux list-session &> /dev/null || () {
  [[ -n ${commands[trash]} ]] && trash auto-delete
}

() { # tmux
  [[ -z ${WINDOWID} ]] && return 1
  [[ "$(ps hco cmd ${PPID})" =~ 'termite|alacritty' ]] || return 1
  [[ -n ${commands[tmux_management.sh]} ]] \
    && tmux_management.sh && exit
}
