case ${OSTYPE} in
  darwin* )
    [[ -e ${_CD_FILE} ]] || export _CD_FILE=$(mktemp)
  ;;
  'linux-gnu' )
    [[ -e ${_CD_FILE} ]] || export _CD_FILE=$(mktemp -p /tmp cdh_XXXXXX.tmp)
  ;;
esac

tmux list-session &> /dev/null || () {
  [[ -n ${commands[trash]} ]] && trash auto-delete
}

() { # tmux
  [[ -z ${WINDOWID} ]] && return 1 # GUI
  [[ "$(ps hco cmd ${PPID})" =~ 'termite|alacritty' ]] \
    || return 1
  [[ -n ${commands[tmux_management.sh]} ]] \
    && tmux_management.sh \
    && exit
}

[[ -n ${commands[rbenv]} ]] \
  && eval "$(rbenv init -)" \
  && export PATH="${HOME}/.rbenv/bin:${PATH}"
