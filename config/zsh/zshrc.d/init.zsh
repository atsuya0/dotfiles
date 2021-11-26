if [[ ${OSTYPE} =~ 'darwin' ]]; then
  [[ -e ${_CD_HISTORY} ]] || export _CD_HISTORY=$(mktemp)
else
  [[ -e ${_CD_HISTORY} ]] || export _CD_HISTORY=$(mktemp -p /tmp cdh_XXXXXX.tmp)
fi

{ [[ -n ${commands[tmux]} ]] && tmux list-session &> /dev/null ;} || () {
  [[ -n ${commands[trs]} ]] && trs auto-remove
}

() { # tmux
  if [[ -n ${WSL_INTEROP} ]]; then
    [[ "$(ps hco cmd ${PPID})" =~ 'tmux' ]] && return 1
  elif [[ ${OSTYPE} == 'linux-gnu' ]]; then
    [[ -n ${WINDOWID} && "$(ps hco cmd ${PPID})" =~ 'kitty|alacritty|xfce4-terminal' ]] \
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

# [[ -n ${commands[direnv]} ]] && eval "$(direnv hook zsh)"
