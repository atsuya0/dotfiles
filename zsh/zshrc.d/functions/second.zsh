function second() {
  local second="${GOPATH}/bin/second"
  [[ $1 == 'change' ]] \
    && cd "$(${second} $@ || echo '.')" \
    || "${second}" $@
}

function _second() {
  local ret=1

  function sub_commands() {
    local -a _c

    _c=(
      'change' \
      'register' \
      'list' \
      'delete' \
      'init'
    )

    _describe -t commands Commands _c
  }

  _arguments -C \
    '(-h --help)'{-h,--help}'[show help]' \
    '1: :sub_commands' \
    '*:: :->args' \
    && ret=0

  case "${state}" in
    (args)
      case "${words[1]}" in
        (register)
          _arguments \
            '(-n --name)'{-n,--name}'[Second name]' \
            '(-p --path)'{-p,--path}'[Target path]'
        ;;
        (change)
          _values \
            'Second names' \
            $(second list --name)
        ;;
        (list)
          _arguments \
            '(-n --name)'{-n,--name}'[Second name]' \
            '(-p --path)'{-p,--path}'[Target path]'
        ;;
        (delete)
          _values \
            'Second names' \
            $(second list --name)
        ;;
        (init)
        ;;
      esac
  esac

  return ret
}
compdef _second second

alias sc='second'
