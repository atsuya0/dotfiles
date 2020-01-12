export NVM_DIR="${HOME}/.nvm" # Node.jsのversion管理

export TRASH_CAN_PATH="${HOME}/.Trash"

typeset -a path=(
  $([[ -d ${DOTFILES}/bin ]] && echo ${DOTFILES}/bin)
  $([[ -d ${GOPATH}/bin ]] && echo ${GOPATH}/bin)
  $([[ -n ${commands[ruby]} ]] && echo "$(ruby -e 'print Gem.user_dir')/bin")
)

case ${OSTYPE} in
  darwin* )
    typeset -ar path=(
      ${path}
      /usr/local/opt/coreutils/libexec/gnubin
      /usr/local/opt/findutils/libexec/gnubin
      /usr/local/opt/gnu-sed/libexec/gnubin
      /usr/local/bin
      /usr/bin
      /bin
      /usr/sbin
      /sbin
    )
  ;;
  'linux-gnu' )
    typeset -ar path=(
      ${path}
      /usr/bin
    )
  ;;
esac
