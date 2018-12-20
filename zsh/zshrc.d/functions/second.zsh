function second() {
  [[ $1 == 'change' ]] \
    && eval cd $(command second $@ || echo '.') 2> /dev/null \
    || command second $@
}

function _second() {
  function sub_commands() {
    _values 'Commands' \
      'change' \
      'register' \
      'list' \
      'delete' \
      'init'
  }

  _arguments -C \
    '(-h --help)'{-h,--help}'[show help]' \
    '1: :sub_commands' \
    '*:: :->args'

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
}
compdef _second second

alias sc='second'

function second_with_tmux() {
  type tmux &> /dev/null \
    || { echo 'tmux is required.'; return 1; }
  type second &> /dev/null \
    || { echo 'second is required.';  return 1; }

  [[ $# -eq 0 ]] \
    && { second list --name; return 1; }
  second list --name | grep -q "^$1$" || { echo 'invalid argument'; return 1; }
  tmux ls -F '#{session_name}' | grep -q "^$1$" && { echo 'already exists'; return 1; }

  tmux new-session -s $1 -d -c $(command second change $1)
  tmux switch-client -t $1
}

function _second_with_tmux() {
  _values \
    'Second names' \
    $(second list --name)
}
compdef _second_with_tmux second_with_tmux

alias sct='second_with_tmux'
