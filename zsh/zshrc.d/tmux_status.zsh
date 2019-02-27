# tmuxの左ステータスバー
function __tmux_status__() {
  # tmuxのSession番号を表示。commandがzshのときにはmodeも表示。
  #
  [[ -z ${commands[tmux]} ]] && return 1
  [[ -z ${TMUX} ]] && return 1

  local -r separator=''

  function get_mode() {
    [[ $# -ne 3 ]] && return 1
    echo "#[fg=${2},bg=${3}]#{?#{==:#{pane_current_command},zsh}, -- ${1} -- #[default]#[fg=${3}]#[bg=blue]#{?client_prefix,#[bg=yellow],}${separator},}"
  }

  local mode
  [[ ${KEYMAP} == 'vicmd' ]] \
    && mode=$(get_mode 'NORM' 'black' 'green') \
    || mode=$(get_mode 'INS' 'blue' 'black')

  tmux set -g status-left "${mode}#[fg=black,bg=blue]#{?client_prefix,#[bg=yellow],} S/#S #[default]#[fg=blue]#{?client_prefix,#[fg=yellow],}${separator}"
}
zle -N zle-line-init __tmux_status__
zle -N zle-keymap-select __tmux_status__
