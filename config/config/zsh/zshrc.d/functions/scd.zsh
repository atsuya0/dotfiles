function scd() {
  [[ $1 == 'change' ]] \
    && eval cd $(command scd $@ | grep '/' || echo '.') 2> /dev/null \
    || command scd $@
}

function _scd() {
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
compdef _scd scd

function print_available_session_names() {
  diff --new-line-format='' --old-line-format='%L' --unchanged-line-format='' \
    <(scd list --name) <(tmux ls -F '#{session_name}')
}

function scd_with_tmux_session() {
  [[ -z ${commands[scd]} ]] \
    && { echo 'scd is required.';  return 1; }
  [[ -z ${commands[tmux]} ]] \
    && { echo 'tmux is required.'; return 1; }

  if [[ $# -eq 0 ]]; then
    [[ -z ${commands[fzf]} ]] && { print_available_session_names; return 1; }
    local -r session_name=$(print_available_session_names | fzf)
    [[ -z ${session_name} ]] && return 1
  else
    local -r session_name=$1
    scd list --name \
      | grep -q "^${session_name}$" \
      || { echo 'invalid argument'; return 1; }
    tmux ls -F '#{session_name}' \
      | grep -q "^${session_name}$" \
      && { echo 'already exists'; return 1; }
  fi

  tmux new-session -s ${session_name} -d -c $(command scd change ${session_name})
  tmux switch-client -t ${session_name}
}

function _scd_with_tmux_session() {
  _values \
    'Session names' \
    $(print_available_session_names)
}
compdef _scd_with_tmux_session scd_with_tmux_session

alias tscd='scd_with_tmux_session'
