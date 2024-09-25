if [[ ${OSTYPE} =~ 'darwin' ]]; then
  [[ -e ${_CD_HISTORY} ]] || export _CD_HISTORY=$(mktemp)
else
  [[ -e ${_CD_HISTORY} ]] || export _CD_HISTORY=$(mktemp -p /tmp cdh_XXXXXX.tmp)
fi

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

() { # https://mise.jdx.dev
  [[ -n ${commands[brew]} ]] \
    && eval "$($(brew --prefix mise)/bin/mise activate zsh)"
}

#() { # http://asdf-vm.com/
#  [[ -n ${commands[brew]} ]] \
#    && local -r asdf_sh_brew="$(brew --prefix asdf)/libexec/asdf.sh" \
#    && [[ -e ${asdf_sh_brew} ]] \
#    && { source ${asdf_sh_brew}; return }
#
#  local -r asdf_sh_home="${HOME}/.asdf/asdf.sh"
#  [[ -e ${asdf_sh_home} ]] && { source ${asdf_sh_home}; return }
#
#  local -r asdf_sh_opt='/opt/asdf-vm/asdf.sh'
#  [[ -e ${asdf_sh_opt} ]] && { source ${asdf_sh_opt}; return }
#}

[[ -n ${commands[pyenv]} ]] && eval "$(pyenv init --path)"

# [[ -n ${commands[direnv]} ]] && eval "$(direnv hook zsh)"
