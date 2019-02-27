export NVM_DIR="${HOME}/.nvm" # Node.jsのversion管理

export TRASH_PATH="${HOME}/.Trash"
export SECOND_LIST_PATH="${HOME}/.second_list.json"

typeset -ar path=(
  $([[ -d ${DOTFILES}/script ]] && echo ${DOTFILES}/script)
  $([[ -d ${GOPATH}/bin ]] && echo ${GOPATH}/bin)
  $([[ -n ${commands[ruby]} ]] && echo "$(ruby -e 'print Gem.user_dir')/bin")
  /usr/bin
)

# function manage_solargraph() {
#   [[ -z ${commands[git]} ]] && return 1
#
#   function set_path() {
#     [[ $# -eq 0 ]] \
#       && path=(${org_path[@]}) \
#       || path=($1 ${org_path[@]})
#   }
#
#   git status &> /dev/null || { set_path; return 0; }
#
#   local -r ruby_path="$(git rev-parse --show-toplevel)/vendor/bundle/ruby/"
#   [[ -d ${ruby_path} ]] || { set_path; return 0; }
#
#   local -r solargraph=$( \
#     find ${ruby_path} -name 'solargraph' -type f | head -1 | xargs dirname \
#   )
#   [[ -n ${solargraph} ]] \
#     && set_path ${solargraph} \
#     || set_path
# }
#
# add-zsh-hook precmd manage_solargraph
