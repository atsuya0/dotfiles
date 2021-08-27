setopt hist_ignore_dups # 直前と同じコマンドを記録しない
setopt hist_ignore_all_dups # コマンド履歴を重複させない
setopt hist_ignore_space # spaceで始まるコマンドを記録しない
setopt hist_reduce_blanks # spaceを詰めて記録
setopt share_history # 他のターミナルとコマンド履歴を共有
setopt extended_history # コマンド履歴に時間を追加
setopt hist_no_store # historyコマンドを履歴に登録しない
setopt hist_expand # 補完時に履歴を自動展開
setopt inc_append_history # 対話検索
# 履歴の保存場所
[[ -n ${ZDOTDIR} ]] \
  && HISTFILE="${ZDOTDIR}/.zsh_history" \
  || HISTFILE="${HOME}/.zsh_history"
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
  vi export type which file stat command builtin grep ln cat
  test '\[' '\[\[' sudoedit mount umount echo expr find pactl
  chmod print printf make
  'pacman -Si' 'pacman -Ss' 'pacman -Qi' 'pacman -Qs'

  vim nvim code python 'npm search' xsel tree google-chrome-stable w3m feh rg

  up down dw second sc tsc
  gs ga gd gcm gco gb gmv
  trs bak rs rn crawl cb to_pdf convert mk 'dc exec' 'dc run'
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
