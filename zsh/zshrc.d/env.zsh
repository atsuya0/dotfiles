typeset -gr path=(
  $([[ -d ${GOPATH}/bin ]] && echo ${GOPATH}/bin)
  $(type ruby &> /dev/null \
    && ruby -e 'print Gem.user_dir' \
    | xargs -I{} echo {}/bin
  )
  /usr/bin
  /usr/bin/core_perl
)

export NVM_DIR="${HOME}/.nvm" # Node.jsのversion管理

export TRASH_PATH="${HOME}/.Trash"
export SECOND_LIST_PATH="${HOME}/.second_list"
