source "${ZDOTDIR}/zshrc.d/init.zsh"
source "${ZDOTDIR}/zshrc.d/env.zsh"
# =========================================================================
# その他
# =========================================================================
WORDCHARS='*?_-.[]~=&;!#$%^(){}<>' # 区切りとして扱わない文字。
# 実行したプロセスの消費時間が3秒以上かかったら、消費時間の統計情報を表示する。
REPORTTIME=3
# 画面のロックと解除を無効(C-s,C-q)
setopt no_flow_control
# beep音停止
setopt no_beep
setopt no_list_beep
setopt no_hist_beep
# コマンドの打ち損じを修正
setopt correct
# <C-d>でログアウトしないようにする。
setopt ignore_eof
# リダイレクトで上書き禁止(>)。上書きをする場合は>|を使う。
setopt noclobber
() { # fishのようなsyntax-highlighting
  typeset -r highlighting='/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh'
  [[ -s ${highlighting} ]] && source ${highlighting}
}

autoload -Uz colors && colors
source "${ZDOTDIR}/zshrc.d/prompt.zsh"

# =========================================================================
# tmuxの左のステータスバー
# =========================================================================
function _tmux_status() {
  # tmuxのSession番号を表示。commandがzshのときにはmodeも表示。

  [[ -z ${TMUX} ]] && return
  typeset -r sep=''
  [[ ${KEYMAP} == 'vicmd' ]] \
  && typeset -r mode="#[fg=black,bg=green]#{?#{==:#{pane_current_command},zsh}, -- NORM -- #[default]#[fg=green]#[bg=blue]#{?client_prefix,#[bg=yellow],}${sep},}" \
  || typeset -r mode="#[fg=blue,bg=black]#{?#{==:#{pane_current_command},zsh}, -- INS -- #[default]#[fg=black]#[bg=blue]#{?client_prefix,#[bg=yellow],}${sep},}"

  tmux set -g status-left "${mode}#[fg=black,bg=blue]#{?client_prefix,#[bg=yellow],} S/#S #[default]#[fg=blue]#{?client_prefix,#[fg=yellow],}${sep}"
}
zle -N zle-line-init _tmux_status
zle -N zle-keymap-select _tmux_status

# =========================================================================
# ディレクトリ移動
# =========================================================================
# cdでディレクトリ名を指定するだけで移動できるpath
# cdpath=( ${HOME} )
# cdをpushdにする
setopt auto_pushd
# pushdのスタックを重複しない
setopt pushd_ignore_dups

# =========================================================================
# 補完
# =========================================================================
autoload -Uz compinit && compinit
# 補完時にハイライト tab,C-n,C-f,C-p,C-b
zstyle ':completion:*:default' menu select
# 補完で大文字にも一致
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
# 区切り文字
zstyle ':completion:*' list-separator '->'
# 上記を有効
zstyle ':completion:*:manuals' separate-sections true
# 補完候補に色を付ける
zstyle ':completion:*' list-colors eval $(dircolors -b)
# 説明を緑の太字で表示
zstyle ':completion:*' format '%B%F{green}%d%f%b'
# 補完しないファイル
zstyle ':completion:*:*files' ignored-patterns '*mp3' '.mp4'
# グループ名を表示
#zstyle ':completion:*' group-name ''
# キャッシュ
zstyle ':completion:*' use-cache yes
# 詳細
zstyle ':completion:*' verbose yes
#cd は親ディレクトリからカレントディレクトリを選択しないので表示させないようにする (例: cd ../<TAB>):
# zstyle ':completion:*:cd:*' ignore-parents parent pwd
# zstyle ':completion:*' completer _expand _complete _match _prefix _approximate _list _history
# zstyle ':completion:*:options' description 'yes'
# 補完結果をできるだけ詰める
setopt list_packed
# カッコの対応などを自動的に補完
setopt auto_param_keys
# ディレクトリ名の補完で末尾の/を自動的に付加し次の補完に備える
setopt auto_param_slash
# ファイル名の展開でディレクトリに一致した場合末尾に/を付加する
setopt mark_dirs
# カーソル位置で補完する。
setopt complete_in_word
# globを展開しないで候補の一覧から補完する。
setopt glob_complete
# 辞書順ではなく数字順に並べる。
setopt numeric_glob_sort
# --prefix=~/localというように「=」の後でも
# 「~」や「=コマンド」などのファイル名展開を行う。
setopt magic_equal_subst

# =========================================================================
# 履歴
# =========================================================================
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
# 履歴をメモリに保存する数
HISTSIZE=100000
# 履歴をファイルに保存する数
SAVEHIST=100000
# 入力に対して履歴に一致したコマンドを表示
autoload -Uz history-search-end
zle -N history-beginning-search-forward-end history-search-end
zle -N history-beginning-search-backward-end history-search-end

source "${ZDOTDIR}/zshrc.d/keybind.zsh"
source "${ZDOTDIR}/zshrc.d/fzf.zsh"
source "${ZDOTDIR}/zshrc.d/function.zsh"
source "${ZDOTDIR}/zshrc.d/alias.zsh"
