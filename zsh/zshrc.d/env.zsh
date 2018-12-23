export NVM_DIR="${HOME}/.nvm" # Node.jsのversion管理

export DOTFILES="${HOME}/dotfiles"
export TRASH_PATH="${HOME}/.Trash"
export SECOND_LIST_PATH="${HOME}/.second_list.json"

# ruby製のtoolのpath
type ruby &> /dev/null \
  && local gem_path="$(ruby -e 'print Gem.user_dir')/bin"

typeset -r path=(
  $([[ -d ${DOTFILES}/script ]] && echo ${DOTFILES}/script)
  $([[ -d ${GOPATH}/bin ]] && echo ${GOPATH}/bin)
  ${gem_path}
  /usr/bin
)
