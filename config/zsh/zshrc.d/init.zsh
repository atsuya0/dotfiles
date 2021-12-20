if [[ ${OSTYPE} =~ 'darwin' ]]; then
  [[ -e ${_CD_HISTORY} ]] || export _CD_HISTORY=$(mktemp)
else
  [[ -e ${_CD_HISTORY} ]] || export _CD_HISTORY=$(mktemp -p /tmp cdh_XXXXXX.tmp)
fi

{ [[ -n ${commands[tmux]} ]] && tmux list-session &> /dev/null ;} || () {
  [[ -n ${commands[trs]} ]] && trs auto-remove

  # [[ -n ${WSL_INTEROP} ]] \
  #   && export DISPLAY=$(hostname).mshome.net:0.0
  # https://docs.microsoft.com/ja-jp/windows/wsl/troubleshooting#bash-loses-network-connectivity-once-connected-to-a-vpn
  #[[ -n ${WSL_INTEROP} && -w /etc/resolv.conf ]] \
  #  && echo 'nameserver 8.8.8.8' >> /etc/resolv.conf

  [[ -n ${WSL_INTEROP} ]] \
    && export DISPLAY="$(ip route show scope global | grep -o '[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*'):0.0"
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

() { # http://asdf-vm.com/
  local -r asdf_sh="${HOME}/.asdf/asdf.sh"
  [[ -n ${asdf_sh} ]] && source ${asdf_sh}
}

[[ -n ${commands[pyenv]} ]] && eval "$(pyenv init --path)"

# [[ -n ${commands[direnv]} ]] && eval "$(direnv hook zsh)"
