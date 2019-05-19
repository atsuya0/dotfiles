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
