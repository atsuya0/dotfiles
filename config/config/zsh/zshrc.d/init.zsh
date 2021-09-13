[[ ${OSTYPE} =~ 'darwin' ]] \
  && [[ -e ${_CD_FILE} ]] || export _CD_FILE=$(mktemp) \
  || [[ -e ${_CD_FILE} ]] || export _CD_FILE=$(mktemp -p /tmp cdh_XXXXXX.tmp)

{ [[ -n ${commands[tmux]} ]] && tmux list-session &> /dev/null ;} || () {
  [[ -n ${commands[trs]} ]] && trs auto-remove
}

() { # tmux
  if [[ ${OSTYPE} == 'linux-gnu' ]]; then
    [[ -n ${WINDOWID} && "$(ps hco cmd ${PPID})" =~ 'kitty|alacritty' ]] \
      || return 1
  else
    [[ "$(ps co comm ${PPID} | tail -1)" == 'tmux' ]] && return 1
  fi
  [[ -z ${commands[tmux_management.sh]} ]] && return 1
  tmux_management.sh && exit
}

[[ -n ${commands[rbenv]} ]] \
  && eval "$(rbenv init -)" \
  && export PATH="${HOME}/.rbenv/bin:${PATH}"

[[ -n ${commands[direnv]} ]] && eval "$(direnv hook zsh)"
