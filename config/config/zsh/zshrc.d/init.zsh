[[ ${OSTYPE} =~ 'darwin' ]] \
  && [[ -e ${_CD_FILE} ]] || export _CD_FILE=$(mktemp) \
  || [[ -e ${_CD_FILE} ]] || export _CD_FILE=$(mktemp -p /tmp cdh_XXXXXX.tmp)

{ [[ -n ${commands[tmux]} ]] && tmux list-session &> /dev/null ;} || () {
  [[ -n ${commands[trs]} ]] && trs auto-remove
}

() { # tmux
  [[ ${OSTYPE} == 'linux-gnu' && -z ${WINDOWID} &&  ! "$(ps hco cmd ${PPID})" =~ 'termite|alacritty' ]] \
    && return 1
  [[ -n ${commands[tmux_management.sh]} ]] \
    && tmux_management.sh \
    && exit
}

[[ -n ${commands[rbenv]} ]] \
  && eval "$(rbenv init -)" \
  && export PATH="${HOME}/.rbenv/bin:${PATH}"

[[ -n ${commands[direnv]} ]] && eval "$(direnv hook zsh)"
