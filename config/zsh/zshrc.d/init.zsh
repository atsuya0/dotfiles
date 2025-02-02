[[ -e ${_CD_HISTORY} ]] || export _CD_HISTORY=$(mktemp)

{ [[ -n ${commands[tmux]} ]] && tmux list-session &> /dev/null ;} || () {
  [[ -n ${commands[trs]} ]] && trs auto-remove

  # https://docs.microsoft.com/ja-jp/windows/wsl/troubleshooting#bash-loses-network-connectivity-once-connected-to-a-vpn
  #[[ -n ${WSL_INTEROP} && -w /etc/resolv.conf ]] \
  #  && echo 'nameserver 8.8.8.8' >> /etc/resolv.conf
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

# A list of non-alphanumeric characters considered part of a word by the line editor.
WORDCHARS='*?_-[]~&;!#$%^(){}<>' # /\=|.,

() { # https://mise.jdx.dev
  [[ -z ${commands[mise]} ]] && return
  [[ -n ${commands[brew]} ]] \
    && eval "$($(brew --prefix mise)/bin/mise activate zsh)"
}
[[ -n ${commands[pyenv]} ]] && eval "$(pyenv init --path)"
[[ -n ${commands[scd]} ]] && source <(scd script)
