export VOLTA_HOME="${HOME}/.volta"
export DENO_INSTALL="${HOME}/.deno"

typeset -a path=(
  $([[ -d ${DOTFILES}/bin ]] && echo ${DOTFILES}/bin)
  $([[ -d ${GOPATH}/bin ]] && echo ${GOPATH}/bin)
  $([[ -d ${VOLTA_HOME}/bin ]] && echo ${VOLTA_HOME}/bin)
  $([[ -d ${DENO_INSTALL}/bin ]] && echo ${DENO_INSTALL}/bin)
  $([[ -n ${commands[ruby]} \
    && -d "$(ruby -e 'print Gem.user_dir')/bin" ]] \
      && echo "$(ruby -e 'print Gem.user_dir')/bin")
)

if [[ ${OSTYPE} =~ 'darwin' ]]; then
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
elif [[ -n ${WSLENV} ]]; then
  export TRASH_CAN_PATH="${HOME}/.Trash"
  typeset -ar path=(
    ${path}
    /usr/bin
    /usr/local/bin
    '/mnt/c/Windows/System32/WindowsPowerShell/v1.0'
    '/mnt/c/Users/atsuy/AppData/Local/Programs/Microsoft VS Code/bin'
  )
elif [[ ${OSTYPE} == 'linux-gnu' ]]; then
  export TRASH_CAN_PATH="${HOME}/.Trash"
  typeset -ar path=(
    ${path}
    /usr/bin
  )
fi