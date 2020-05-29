function second() {
  [[ $1 == 'change' ]] \
    && eval cd $(command second $@ | grep '/' || echo '.') 2> /dev/null \
    || command second $@
}

function _second() {
  function sub_commands() {
    _values 'Commands' \
      'change' \
      'show' \
      'register' \
      'list' \
      'remove' \
      'init'
  }

  _arguments -C \
    '(-h --help)'{-h,--help}'[help]' \
    '1: :sub_commands' \
    '*:: :->args'

  case "${state}" in
    (args)
      case "${words[1]}" in
        (register)
          _arguments \
            '(-n --name)'{-n,--name}'[Second name]' \
            '(-p --path)'{-p,--path}'[Target path]' \
            '(-s --sub)'{-s,--sub}'[sub directory]'
        ;;
        (change)
          _arguments \
            '(-s --sub)'{-s,--sub}'[sub directory]'
        ;;
        (show)
          _values \
            'Second names' \
            $(second list --name)
        ;;
        (list)
          _arguments \
            '(-n --name)'{-n,--name}'[Second name]' \
            '(-p --path)'{-p,--path}'[Target path]'
        ;;
        (remove)
          _arguments \
            '(-s --sub)'{-s,--sub}'[sub directory]'
        ;;
        (init)
        ;;
      esac
  esac
}
compdef _second second

alias sc='second'

function print_available_session_names() {
  diff --new-line-format='' --old-line-format='%L' --unchanged-line-format='' \
    <(second list --name) <(tmux ls -F '#{session_name}')
}

function second_with_tmux_session() {
  [[ -z ${commands[second]} ]] \
    && { echo 'second is required.';  return 1; }
  [[ -z ${commands[tmux]} ]] \
    && { echo 'tmux is required.'; return 1; }

  if [[ $# -eq 0 ]]; then
    [[ -z ${commands[fzf]} ]] && { print_available_session_names; return 1; }
    local -r session_name=$(print_available_session_names | fzf)
    [[ -z ${session_name} ]] && return 1
  else
    local -r session_name=$1
    second list --name \
      | grep -q "^${session_name}$" \
      || { echo 'invalid argument'; return 1; }
    tmux ls -F '#{session_name}' \
      | grep -q "^${session_name}$" \
      && { echo 'already exists'; return 1; }
  fi

  tmux new-session -s ${session_name} -d -c $(command second show ${session_name})
  tmux switch-client -t ${session_name}
}

function _second_with_tmux_session() {
  _values \
    'Session names' \
    $(print_available_session_names)
}
compdef _second_with_tmux_session second_with_tmux_session

alias tsc='second_with_tmux_session'
