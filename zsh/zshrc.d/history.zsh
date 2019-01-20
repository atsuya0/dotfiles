# 直前と同じコマンドを記録しない
setopt hist_ignore_dups
# コマンド履歴を重複させない
setopt hist_ignore_all_dups
# spaceで始まるコマンドを記録しない
setopt hist_ignore_space
# spaceを詰めて記録
setopt hist_reduce_blanks
# 他のターミナルとコマンド履歴を共有
setopt share_history
# コマンド履歴に時間を追加
setopt extended_history
# historyコマンドを履歴に登録しない
setopt hist_no_store
# 補完時に履歴を自動展開
setopt hist_expand
# 対話検索
setopt inc_append_history
# 履歴の保存場所
[[ -n ${ZDOTDIR} ]] && HISTFILE="${ZDOTDIR}/.zsh_history" || HISTFILE="${HOME}/.zsh_history"
HISTSIZE=100000 # 履歴をメモリに保存する数
SAVEHIST=100000 # 履歴をファイルに保存する数
# 入力に対して履歴に一致したコマンドを表示
autoload -Uz history-search-end
zle -N history-beginning-search-forward-end history-search-end
zle -N history-beginning-search-backward-end history-search-end

# コマンドの終了ステータスを見てファイルに記録するか否かを決めたいので、
# ここではファイルには記録しない。
# 0 記録する, 1 記録しない, 2 メモリにだけ記録する
function __record_cmd__() {
  typeset -g _cmd=${1%%$'\n'}
  return 2
}
add-zsh-hook zshaddhistory __record_cmd__

# 履歴に記録しないコマンドを記述
typeset -ar __ignore_cmds__=(
  ls cd mv cp rm mkdir rmdir touch man less history source '\.'
  vi export type which file stat command builtin grep ln cat wall
  test '\[' '\[\[' sudoedit mount umount kill pkill pgrep echo
  expr seq find pactl jobs fc-list chmod pwd ps date print printf
  'sudo systemctl start' 'sudo systemctl stop' 'systemctl status'
  'pacman -Si' 'pacman -Ss' 'pacman -Qi' 'pacman -Qs'

  vim nvim code python go 'npm search' xsel tmux tree chromium
  rofi notify-send w3m scrot feh rg

  up down dw gcm gp gmv second sc tsc trash trs bak rs rn cc fonts
  twi
)

function __save_cmd__() {
  local -r exit_status=$?
  _cmd=$(tr -s ' ' <<< ${_cmd}) # 連続する空白を1つにす
  [[ ! ${_cmd} =~ ' ' ]] && return # 引数やオプションを指定していない場合は記録しない
  [[ ${_cmd} =~ '^ ' ]] && return

  local ignore_cmd
  for ignore_cmd in ${__ignore_cmds__[@]}; do
    [[ ${_cmd} =~ "^${ignore_cmd}" ]] && return
  done
  # コマンドが正常終了した場合はファイルに記録する
  [[ ${exit_status} == 0 ]] && print -sr -- "${_cmd}"
}
add-zsh-hook precmd __save_cmd__
