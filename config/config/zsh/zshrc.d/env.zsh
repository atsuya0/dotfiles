export VOLTA_HOME="${HOME}/.volta"

typeset -a path=(
  $([[ -d ${DOTFILES}/bin ]] && echo ${DOTFILES}/bin)
  $([[ -d ${GOPATH}/bin ]] && echo ${GOPATH}/bin)
  $([[ -d ${VOLTA_HOME}/bin ]] && echo ${VOLTA_HOME}/bin)
  $([[ -n ${commands[ruby]} \
    && -d "$(ruby -e 'print Gem.user_dir')/bin" ]] \
      && echo "$(ruby -e 'print Gem.user_dir')/bin")
)

case ${OSTYPE} in
  darwin* )
    export TRASH_CAN_PATH="${HOME}/Trash"
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
      /usr/local/opt/mysql@5.6/bin
      "${HOME}/google-cloud-sdk/bin"
    )
  ;;
  'linux-gnu' )
    export TRASH_CAN_PATH="${HOME}/.Trash"
    typeset -ar path=(
      ${path}
      /usr/bin
    )
  ;;
esac
