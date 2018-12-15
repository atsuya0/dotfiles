function rails() {
  type docker-compose &> /dev/null || return 1
  docker info &> /dev/null || return 1
  [[ $# -eq 0 ]] && return 1

  docker-compose run --rm rails rails $@
}

function _rails() {
  local ret=1

  function sub_commands() {
    local -a _c=(
      'bundle'
      'generate'
      'db\:setup'
      'db\:reset'
      'db\:seed'
      'db\:migrate'
      'db\:migrate\:reset'
      'db\:rollback'
    )

    _describe -t commands Commands _c
  }

  _arguments -C \
    '1: :sub_commands' \
    '*:: :->args' \
    && ret=0

  case ${state} in
    (args)
      case ${words[1]} in
        (generate)
          _values 'menu' \
          'controller' \
          'view' \
          'model'
        ;;
        (bundle)
          _values 'menu' \
          'update' \
          'init'
        ;;
      esac
    ;;
  esac

  return ret
}

compdef _rails rails
