# tmuxの左ステータスバー
function __tmux_status__() {
  # tmuxのSession番号を表示。commandがzshのときにはmodeも表示。

  [[ -z ${TMUX} ]] && return 1
  local -r separator=''
  [[ ${KEYMAP} == 'vicmd' ]] \
    && local -r \
      mode="#[fg=black,bg=green]#{?#{==:#{pane_current_command},zsh}, -- NORM -- #[default]#[fg=green]#[bg=blue]#{?client_prefix,#[bg=yellow],}${separator},}" \
    || local -r \
      mode="#[fg=blue,bg=black]#{?#{==:#{pane_current_command},zsh}, -- INS -- #[default]#[fg=black]#[bg=blue]#{?client_prefix,#[bg=yellow],}${separator},}"

  tmux set -g status-left "${mode}#[fg=black,bg=blue]#{?client_prefix,#[bg=yellow],} S/#S #[default]#[fg=blue]#{?client_prefix,#[fg=yellow],}${separator}"
}
zle -N zle-line-init __tmux_status__
zle -N zle-keymap-select __tmux_status__
