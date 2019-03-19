function rails() {
  type docker-compose &> /dev/null || return 1
  docker info &> /dev/null || return 1
  [[ $# -eq 0 ]] && return 1

  [[ $1 != 'bin/bundle' ]] \
    && docker-compose run --rm rails bin/rails $@ \
    || docker-compose run --rm rails $@
}

function _rails() {
  function sub_commands() {
    _values 'Commands' \
      'bin/bundle' \
      'generate' \
      'test' \
      'console' \
      'db\:setup' \
      'db\:seed' \
      'db\:migrate' \
      'db\:migrate\:reset' \
      'db\:rollback' \
      'db\:seed'
  }

  _arguments -C \
    '1: :sub_commands' \
    '*:: :->args'

  case ${state} in
    (args)
      case ${words[1]} in
        (generate)
          _values 'menu' \
          'controller' \
          'view' \
          'model' \
          'integration_test' \
          'mailer'
        ;;
        (bin/bundle)
          _values 'menu' \
          'exec' \
          'init'
        ;;
        (console)
          _values 'menu' \
          '--sandbox'
        ;;
      esac
    ;;
  esac
}

compdef _rails rails
