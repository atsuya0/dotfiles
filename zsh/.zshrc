[[ -e ${_CD_FILE} ]] || export _CD_FILE=$(mktemp)
# =========================================================================
# installed tmux && installed fzf && sessionが存在しない && GUI && True Color対応の仮想端末であるmlterm => tmux起動
# =========================================================================
type tmux > /dev/null 2>&1 && type fzf > /dev/null 2>&1 \
&& [[ -z ${TMUX} \
      && -n ${WINDOWID} \
      && $(ps -ho args ${PPID} | tr -s ' ' | cut -d' ' -f1) == 'mlterm' \
]] && () {
  local new='new-session'
  id=$(
    echo "$(tmux list-sessions 2> /dev/null)\n${new}:" \
    | sed /^$/d | fzf --select-1 --reverse | cut -d: -f1
  )

  if [[ ${id} = ${new} ]]; then
    tmux -f "${HOME}/dotfiles/tmux/tmux.conf" -2 new-session && exit
  elif [[ -n ${id} ]]; then
    tmux attach-session -t ${id}
  fi
} && return
# =========================================================================
# 環境変数
# =========================================================================
readonly path=(
  ${GOPATH}/bin
  $(ruby -e 'print Gem.user_dir')/bin
  /usr/bin
  /usr/bin/core_perl
)
export GREP_COLOR='1;33' # grep
export LESS='-iMRgW -j10 -x2 --no-init --quit-if-one-screen +5' # less
export LESS_TERMCAP_mb=$(echo -n '\e[34;1m')
export LESS_TERMCAP_md=$(echo -n '\e[34;1m')
export LESS_TERMCAP_me=$(echo -n '\e[37m')
export LESS_TERMCAP_se=$(echo -n '\e[37m')
export LESS_TERMCAP_so=$(echo -n '\e[31;40;1m')
export LESS_TERMCAP_ue=$(echo -n '\e[32;1m')
export LESS_TERMCAP_us=$(echo -n '\e[32;1m')
export MANPAGER='less' # man
export NVM_DIR="${HOME}/.nvm" # Node.jsのversion管理
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

# =========================================================================
# プロンプト
# =========================================================================
autoload -Uz colors && colors

function _dir_prompt() { # カレントディレクトリのpathを画面の横幅に応じて短縮する。
  typeset -r pwd=$(pwd | sed "s@${HOME}@~@")
  local num
  # 表示するディレクトリ名の文字数を決める
  let num=$(expr $(tput cols) - 55 | xargs -I{} sh -c "test 1 -gt {} && echo 1 || echo {}")/$(echo ${pwd} | grep -o '[~/]' | wc -l)
  [[ ${num} -eq 0 ]] && num=1

  # CUI/neovim と GUI で表示を変える
  [[ -z ${WINDOWID} || $(ps -ho args ${PPID} | tr -s ' ' | cut -d' ' -f1) == 'nvim' ]] \
    && PROMPT="%n@%m ${fg[blue]}$(echo ${pwd} | sed "s@\(/[^/]\{${num}\}\)[^/]*@\1@g")${reset_color} " \
    || PROMPT="%{${fg[blue]}${bg[black]}%}%n%{${fg[magenta]}${bg[black]}%}@%{${fg[blue]}${bg[black]}%}%m %{${fg[black]}${bg[blue]}%}%{${fg[black]}${bg[blue]}%} $(echo ${pwd} | sed "s@\(/[^/]\{${num}\}\)[^/]*@\1@g") %{${reset_color}${fg[blue]}%} "
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _dir_prompt

function _git_prompt() {
  RPROMPT=''
  type git > /dev/null 2>&1 || return 1
  git status > /dev/null 2>&1 || return 1
  local git_info=("${(f)$(git status --porcelain --branch)}")

  local branch="[$(echo ${git_info[1]} | sed 's/## \([^\.]*\).*/\1/')]"
  if [[ $(echo ${git_info[1]} | grep -o '\[.*\]') =~ '[ahead .*]' ]]; then
    branch="%{${fg[blue]}%}${branch}"
  elif [[ $(echo ${git_info[1]} | grep -o '\[.*\]') =~ '[behind .*]' ]]; then
    branch="%{${fg[red]}%}${branch}"
  else
    branch="%{${fg[green]}%}${branch}"
  fi

  local file uncommited=0 unadded=0 untracked=0
  for file in ${git_info[2,-1]}; do
    if [[ $(echo ${file} | cut -c1-2) == '??' ]]; then
      (( untracked++ ))
    elif [[ $(echo ${file} | cut -c1-2) =~ '( |M|A|R|U)(M|D|U)' ]]; then
      (( unadded++ ))
    elif [[ $(echo ${file} | cut -c1-2) =~ '(M|A|R|D) ' ]]; then
      (( uncommited++ ))
    fi
  done
  local git_status
  [[ ${uncommited} -ne 0 ]] && git_status="%{${fg[yellow]}%}!${uncommited} "
  [[ ${unadded} -ne 0 ]] && git_status="${git_status}%{${fg[red]}%}+${unadded} "
  [[ ${untracked} -ne 0 ]] && git_status="${git_status}%{${fg[green]}%}?${untracked} "
  RPROMPT="${git_status}${branch}"
}
add-zsh-hook precmd _git_prompt

# rangerでshellを起動したときにPROMPTの先頭にR_を付ける
[[ -n ${RANGER_LEVEL} ]] && PROMPT="R_${PROMPT}"
# コマンド実行後にRPROMPTを非表示
setopt transient_rprompt

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

# =========================================================================
# キーバインド
# =========================================================================
# プロンプトでviのキーバインドを使う。
bindkey -v
# 挿入モードをemacsにする
bindkey -M viins '^f'  forward-char
bindkey -M viins '^b'  backward-char
bindkey -M viins '^a'  beginning-of-line
bindkey -M viins '^e'  end-of-line
bindkey -M viins '^d'  delete-char-or-list
bindkey -M viins '^h'  backward-delete-char
bindkey -M viins '^w'  backward-kill-word
bindkey -M viins '^u'  backward-kill-line
bindkey -M viins '^k'  kill-line
bindkey -M viins '^y'  yank
bindkey -M viins '^n'  down-line-or-history
bindkey -M viins '^p'  up-line-or-history
bindkey -M viins '^s' history-incremental-search-forward
bindkey -M viins '^r' history-incremental-search-backward
# bindkey -M viins '^s' history-incremental-pattern-search-forward
# bindkey -M viins '^r'  history-incremental-pattern-search-backward
bindkey -M viins '\ef' forward-word #ALT : \e ^[
bindkey -M viins '\eb' backward-word
bindkey -M viins '\ed' kill-word
bindkey -M viins '\e.' insert-last-word
# 入力に対して履歴に一致したコマンドを表示する機能をバインド
bindkey -M viins '\en' history-beginning-search-forward-end
bindkey -M viins '\ep' history-beginning-search-backward-end

# =========================================================================
# fzf (A command-line fuzzy finder) 用の設定
# =========================================================================
# <C-y>で文字列をコピー
export FZF_DEFAULT_OPTS="-m --height=80% --reverse --exit-0 --bind 'ctrl-y:execute-silent(echo {} | xsel -ib)+abort'"
# <C-v>で見切れたコマンドを表示
export FZF_CTRL_R_OPTS="--preview='echo {}' --preview-window=down:3:hidden:wrap --bind 'ctrl-v:toggle-preview'"
# FZF_DEFAULT_COMMAND FZF_ALT_C_COMMAND FZF_ALT_C_OPTS

() { # fzfの拡張を読み込む
  typeset -r fzf_dir='/usr/share/fzf'
  readonly local  keybind="${fzf_dir}/key-bindings.zsh"
  typeset -r completion="${fzf_dir}/completion.zsh"
  [[ -s ${keybind} ]] && source ${keybind}
  [[ -s ${completion} ]] && source ${completion}
}

# _fzf_cd_widget(), vim() で用いる。無視するディレクトリを絶対パスで指定する。
typeset -r ignore_absolute_pathes=(
  ${HOME}/.cache/dein/repos
  ${HOME}/.cache/dein/.cache
  ${HOME}/.cache/pip
  ${HOME}/.cache/jedi
  ${HOME}/.cache/yarn
  ${HOME}/.cache/go-build
  ${HOME}/.cache/fontconfig
  ${HOME}/.cache/neosnippet
  ${HOME}/.cache/typescript/2.6
  ${HOME}/.cache/chromium
  ${HOME}/.config/chromium
  ${HOME}/.config/pulse
  ${HOME}/.config/VirtualBox
  ${HOME}/.config/fcitx
  ${HOME}/.config/Code
  ${HOME}/.config/undo
  ${HOME}/.node-gyp
  ${HOME}/.electron-gyp
  ${HOME}/.rustup
  ${HOME}/.cargo
  ${HOME}/.vscode/extensions
  ${HOME}/.npm/_cacache
  ${HOME}/.Trash
  ${HOME}/text/etc/gowebprog-master
  ${GOPATH}/pkg
  ${GOPATH}/src/gopkg.in
  ${GOPATH}/src/github.com
  ${GOPATH}/src/golang.org
)

function _fzf_cd_widget() {
  # ALT_Cにbindされてるwidgetを上書きしている。
  # 現階層以下のディレクトリからfzfを使って選び移動する。

  local dir
  for dir in ${ignore_absolute_pathes}; do
    local argument="${argument} -path ${dir/$(pwd)/.} -prune -o"
  done

  dir=$(eval find -mindepth 1 ${argument} -type d -print 2> /dev/null \
    | cut -c3- | fzf --select-1 --preview='tree -C {} | head -200' --preview-window='right:hidden' --bind='ctrl-v:toggle-preview')
  eval builtin cd ${dir:-.}

  _dir_prompt
  zle reset-prompt
}
zle   -N  _fzf_cd_widget
bindkey '\ec' _fzf_cd_widget


# =========================================================================
# 関数
# =========================================================================
function bash() { # bash終了時に.bash_historyを削除する。
  cmd_exists bash || return
  command bash
  trap "command rm ${HOME}/.bash_history" EXIT
}

function ls() { # 何も表示されないならば隠しファイルの表示を試みる。
  [[ $(command ls $@) == "" ]] \
    && command ls -FA --color=auto $@ \
    || command ls -F --color=auto $@
}

function cp() {
  # 引数が指定されていないなら選択的インターフェースで選択する
  # 1回目の選択でコピー元を選択する。複数選択可。
  # 2回目でコピー先を選択する。ヘッダにコピー元のファイル・ディレクトリが表示される。

  [[ $# -ne 0 ]] && command cp -i $@ && return

  local dir
  for dir in ${ignore_absolute_pathes}; do
    local argument="${argument} -path ${dir/$(pwd)/.} -prune -o"
  done

  # 元
  source=($(eval find -mindepth 1 ${argument} -print 2> /dev/null \
    | cut -c3- \
    | fzf --select-1 --preview='tree -c {} | head -200' \
      --preview-window='right:hidden' --bind='ctrl-v:toggle-preview'))

  [[ ${#source[@]} -eq 0 ]] && return

  # 宛先
  destination=$(eval find -mindepth 1 ${argument} -print 2> /dev/null \
    | cut -c3- \
    | fzf --select-1 --header="${source}" \
    --preview='tree -c {} | head -200' --preview-window='right:hidden' \
    --bind='ctrl-v:toggle-preview')

  [[ -n ${destination} ]] && command cp -ri ${source} -t ${destination}
}

function mv() { # cp と同じ
  [[ $# -ne 0 ]] && command mv -i $@ && return

  local dir
  for dir in ${ignore_absolute_pathes}; do
    local argument="${argument} -path ${dir/$(pwd)/.} -prune -o"
  done

  source=($(eval find -mindepth 1 ${argument} -print \
    | cut -c3- \
    | fzf --select-1 --preview='tree -c {} | head -200' \
    --preview-window='right:hidden' --bind='ctrl-v:toggle-preview'))

  [[ ${#source[@]} -eq 0 ]] && return

  destination=$(eval find -mindepth 1 ${argument} -print \
    | cut -c3- \
    | fzf --select-1 --header="${source}" \
    --preview='tree -c {} | head -200' --preview-window='right:hidden' \
    --bind='ctrl-v:toggle-preview')

  [[ -n ${destination} ]] && command mv -i ${source} -t ${destination}
}

function mount() {
  # fat32なら現在のユーザで弄れるようにする
  # ディレクトリを省略すると~/mntにマウントする

  [[ $# -eq 0 ]] && command mount && return

  local mnt="${HOME}/mnt"
  [[ -e ${mnt} ]] || mkdir ${mnt}
  [[ $# -eq 1 ]] && set $1 ${mnt}

  [[ $(sudo file -s $1 | cut -d' ' -f2) == 'DOS/MBR' ]] \
    && sudo \mount -o uid=$(id -u),gid=$(id -g) $1 $2 \
    || sudo \mount $1 $2
}

function umount() {
  [[ $# -eq 0 ]] \
    && local mnt="${HOME}/mnt" \
    && sudo \umount ${mnt} \
    && rmdir ${mnt} \
    && return
  command umount $@
}

function history() { # historyの実行時に引数を指定しないなら全ての履歴を表示。
  [[ $# -eq 0 ]] && builtin history -i 1 || builtin history $@
}

function vim(){ # vimで開くファイルをfilterで選択する。
  # nvim > vim > vi の優先度で起動する。
  if cmd_exists nvim; then
    typeset -r editor='nvim'
  elif cmd_exists vim; then
    typeset -r editor='vim'
  else
    typeset -r editor='vi'
  fi

  if [[ $# -eq 0 ]] && type fzf > /dev/null 2>&1; then

    # 無視するディレクトリ(絶対path指定)
    local arg dir
    for dir in ${ignore_absolute_pathes}; do
      arg="${arg} -path ${dir/$(pwd)/.} -prune -o"
    done
    # 無視する拡張子
    local ignore_filetypes=( pdf png jpg jpeg mp3 mp4 tar.gz zip )
    local ftype
    for ftype in ${ignore_filetypes}; do
      arg="${arg} -path "\'\*${ftype}\'" -prune -o"
    done

    # 無視するディレクトリ(ディレクトリ名指定)
    local ignore_dirs=(
      node_modules .git gems vendor cache .WebStorm2018.1 data_docker-compose
      data-mariadb
    )
    for dir in ${ignore_dirs}; do
      arg="${arg} -path "\'\*${dir}\*\'" -prune -o"
    done

    local file=$(eval find ${arg} -type f -print | cut -c3- \
      | fzf --select-1 --preview='less {}' --preview-window='right:hidden' --bind='ctrl-v:toggle-preview')
    [[ -n ${file} ]] && command ${editor} ${file}
  else
    command ${editor} $@
  fi
}

function urxvt() { # 簡単にフォントサイズを指定して起動する。
  [[ $# -eq 0 ]] && command urxvt $@ && return
  expr $1 + 1 > /dev/null 2>&1
  [[ $? -ne 2 ]] && command urxvt --font "xft:Ricty Discord:size=$1"
}

function ranger() { # rangerのサブシェルでネストしないようにする。
  [[ -z $RANGER_LEVEL ]] && command ranger $@ || exit
}

function w3m(){
  # 引数に検索したい単語を渡せばgoogle検索を行う
  # w3m search windows bsd linux

  [[ $1 == 'search' && $# -ge 2 ]] && { \
    local i parameter="search?&q=$2"
    for i in {3..$#}; do
      parameter="${parameter}+$argv[$i]"
    done
    parameter="http://www.google.co.jp/${parameter}&ie=UTF-8"

    command w3m ${parameter}
  } || command w3m $@
}

function scrot() { # スクリーンショット
  [[ $# -eq 0 ]] \
    && command scrot -q 100 '%Y-%m-%d_%H:%M:%S.png' -e '[[ -d ~/Content/pictures/screenshot/ ]] && mv $f ~/Content/pictures/screenshot/' \
    || command scrot $@
}

function init_nvm() { # nvm(Node.jsのversion管理)の初期設定を読み込む
  unset -f $1
  local nvm_dir='/usr/share/nvm'
  [[ -e "${nvm_dir}/nvm.sh" ]] && source "${nvm_dir}/nvm.sh"
  [[ -e "${nvm_dir}/bash_completion" ]] && source "${nvm_dir}/bash_completion"
}

function nvm() {
  init_nvm nvm
  nvm $@
}

function npm() {
  init_nvm npm
  npm $@
}

function node() {
  init_nvm node
  node $@
}

function ng() {
  init_nvm ng
  ng $@
}

function vol() {
  # vol up    -> 音量を5%上げる
  # vol down  -> 音量を5%下げる
  # vol mute  -> muteの切り替え
  # vol       -> 音量を表示

  function get_index() {
    [[ $(pactl list sinks | grep 'RUNNING') != '' ]] \
      && pactl list sinks | grep -B 1 'RUNNING' | grep -o '[0-9]' \
      || pactl list sinks | head -1 | grep -o '[0-9]'
  }

  if [[ $1 == up ]]; then
    pactl set-sink-volume $(get_index) +5%
  elif [[ $1 == down ]]; then
    pactl set-sink-volume $(get_index) -5%
  elif [[ $1 == mute ]]; then
    pactl set-sink-mute $(get_index) toggle
  else
    local run
    [[ $(pactl list sinks | grep 'RUNNING') != '' ]] && run="grep -A 10 'RUNNING'" || run='tee'
    pactl list sinks | eval ${run} | grep -o '[0-9]*%' | head -1
  fi
}

function wifi() {
  if [[ $1 == '-r' ]]; then # 再始動
    netctl list | sed '/^\*/!d;s/[\* ]*//' | xargs sudo netctl restart
  elif [[ $1 == '-s' ]]; then
    netctl list | sed '/^\*/!d;s/[\* ]*//' | xargs sudo netctl stop
  elif type fzf > /dev/null 2>&1; then
    netctl list | fzf --select-1 | xargs sudo netctl start
  fi
}

function colors(){
  for fore in {30..37}; do
    echo "\e[${fore}m \\\e[${fore}m \e[m"
    for mode in 1 4 5; do
      echo -n "\e[${fore};${mode}m \\\e[${fore};${mode}m \e[m"
      for back in {40..47}; do
        echo -n "\e[${fore};${back};${mode}m \\\e[${fore};${back};${mode}m \e[m"
      done
      echo
    done
    echo
  done
}

function cmd_exists(){ # 関数やaliasに囚われないtype,which。 vim()で使う。
  [[ -n $(echo ${PATH//:/\\n} | xargs -I{} find {} -type f -name $1) ]] && return 0 || return 1
}

function up() {
  # 親階層に移動する
  # up 2    -> cd ../..
  # up      -> filterを使って選択する

  local str

  if [[ $# -eq 0 ]] && type fzf > /dev/null 2>&1; then
    str=$(pwd | sed ':a;s@/[^/]*$@@;p;/^\/[^/]*$/!ba;d' \
      | fzf --preview='tree -C {}' --preview-window='right:hidden' --bind='ctrl-v:toggle-preview')
  elif expr ${1-dummy} + 1 > /dev/null 2>&1; then
    str=$(seq -s: $1 | sed 's/://g;s@.@\.\./@g')
  elif [[ -d $1 ]]; then
    str=$1
  fi

  builtin cd ${str:-.}
}

function _up() {
  _values \
    'parents' \
    $(pwd | sed ':a;s@/[^/]*$@@;p;/^\/[^\/]*$/!ba;d')
}
compdef _up up

function down() {
  # 指定した層までを探索してfilterで選択し移動する。
  # down 3

  type fzf > /dev/null 2>&1 || return 1
  dir=$(eval find -mindepth 1 -maxdepth ${1:-1} -type d -print \
    | cut -c3- | fzf --select-1 --preview='tree -C {} | head -200' --preview-window='right:hidden' --bind='ctrl-v:toggle-preview')
  eval builtin cd ${dir:-.}
}
alias dw='down'

function _save_pwd() { # 移動履歴をファイルに記録する。~, / は記録しない。
  typeset -r pwd=$(pwd | sed "s@${HOME}@~@")
  [[ ${#pwd} -gt 2 ]] && echo ${pwd} >> ${_CD_FILE}
}
add-zsh-hook chpwd _save_pwd

function cdh() { # 移動履歴からfilterを使って選んでcd
  local dir

  case $1 in
    '-l' ) cat ${_CD_FILE} | sort | uniq -c | sort -r | tr -s ' ' ;; # 記録一覧
    '--delete-all' ) : > ${_CD_FILE} ;; # 記録の全消去
    '-d' ) # 記録の消去
      type fzf > /dev/null 2>&1 || return 1

      local opt
      [[ ${OSTYPE} == darwin* ]] && opt='' # BSDのsedの場合は-iに引数(バックアップファイル名)を取る
      cat ${_CD_FILE} \
        | fzf --header='delete directory in the record' --preview='tree -C {}' --preview-window='right:hidden' --bind='ctrl-v:toggle-preview' \
        | xargs -I{} sed -i ${opt} 's@^{}$@@;/^$/d' ${_CD_FILE}
    ;;
    * ) # 記録しているディレクトリを表示 使用頻度順
      if [[ $# -eq 0 ]]; then
        type fzf > /dev/null 2>&1 || return 1
        dir=$(cat ${_CD_FILE} | sort | uniq -c | sort -r | tr -s ' ' | cut -d' ' -f3 \
          | fzf --preview='tree -C {}' --preview-window='right:hidden' --bind='ctrl-v:toggle-preview')
        [[ -z ${dir} ]] && return 1
      fi
      eval cd ${dir:-$1}
    ;;
  esac
}

function _cdh() {
  function visited() {
    _values 'visited' \
      $(cat ${_CD_FILE} | sort | uniq -c | sort -r | awk '{print $2}')
  }
  _arguments \
    '-l[list]' \
    '-d[delete]' \
    '--delete-all[delete all]' \
    '1: :visited'
}
compdef _cdh cdh

function cds() { # pathに別名をつけて移動を早くする。

  [[ -n ${ZDOTDIR} ]] && local saved_dirs=${ZDOTDIR}/.saved_dirs || local saved_dirs=${HOME}/.saved_dirs
  # 記録ファイルがなければ作成
  [[ ! -e ${saved_dirs} ]] && find . -maxdepth 1 -type d -not -name '.*' -printf 'default %f ~/%f\n' > ${saved_dirs}
  local dir alias i action='change'

  for (( i=1; i <= $#; i++ )); do
    case ${argv[$i]} in
      '-t' ) # タグ
        (( i++ ))
        [[ -n ${argv[$i]} && ${argv[$i]} != -* ]] && local tag=${argv[$i]}
      ;;
      '-s' ) # 保存
        local skip=0
        [[ ${action} != 'change' ]] && echo 'option error' >&2 && return 1
        action='save'

        if [[ -n ${argv[$i+1]} && ${argv[$i+1]} != -* ]]; then
          alias=${argv[$i+1]} && (( skip++ ))
        else
          alias=$(basename ${PWD})
        fi

        if [[ -n ${argv[$i+2]} && ${argv[$i+2]} != -* ]]; then
          dir=${argv[$i+2]} && (( skip++ ))
        else
          dir=$(pwd)
        fi
        i=$(( $i + ${skip} )) # -s の引数の数だけループを飛ばす
      ;;
      '-l' ) # 一覧
        [[ ${action} != 'change' ]] && echo 'option error' >&2 && return 1
        action='list'
      ;;
      '-d' ) # 削除
        [[ ${action} != 'change' ]] && echo 'option error' >&2 && return 1
        action='delete'
        [[ -n ${argv[$i+1]} && ${argv[$i+1]} != -* ]] && alias=${argv[$i+1]} && (( i++ ))
      ;;
      '--delete-all' ) # 全削除
        [[ ${action} != 'change' ]] && echo 'option error' >&2 && return 1
        action='delete-all'
      ;;
      '-e' ) # 編集
        [[ ${action} != 'change' ]] && echo 'option error' >&2 && return 1
        action='edit'
      ;;
      '-h' ) # ヘルプ
        [[ ${action} != 'change' ]] && echo 'option error' >&2 && return 1
        action='help'
      ;;
      * )
        alias=${argv[$i]}
      ;;
    esac
  done

  # ファイルから別名とpathを切り出す
  if [[ ${action} == 'change' || ${action} == 'list' || ${action} == 'delete' ]]; then
    local file
    [[ -z ${tag} ]] \
      && file=$(cat ${saved_dirs} | cut -d' ' -f2-3) \
      || file=$(cat ${saved_dirs} | grep "^${tag} " | cut -d' ' -f2-3)
  fi

  function alias_exists() { # 既に登録されている別名か
    local alias
    for alias in $(cat ${saved_dirs} | cut -d' ' -f2); do
      [[ $1 == ${alias} ]] && echo 'alias already used' >&2 && return 1
    done
    return 0
  }

  function directory_exists() { # 既に登録されているdirectoryか
    local dir
    for dir in $(cat ${saved_dirs} | cut -d' ' -f3); do
      [[ $(echo $1 | sed "s@${HOME}@~@") == ${dir} ]] && echo 'directory already exists' >&2 && return 1
    done
    return 0
  }

  function check_file() { # ファイルを直接編集した場合、整合性がとれているか確認する。
    local message
    # 別名が重複
    local duplicateAliases=$(cat ${saved_dirs} | cut -d' ' -f2 | sort | uniq -d)
    [[ -n ${duplicateAliases} ]] && message="\e[31;1m[Duplicate aliases]\e[m\n${duplicateAliases}\n"

    # directoryが重複
    local duplicateDirectories=$(cat ${saved_dirs} | cut -d' ' -f3 | sort | uniq -d)
    [[ -n ${duplicateDirectories} ]] && message="${message}\e[31;1m[Duplicate directory]\e[m\n${duplicateDirectories}\n"

    # directoryではないものを登録していないか
    local dir incorrent
    for dir in $(cat ${saved_dirs} | cut -d' ' -f3 | sort | uniq); do
      [[ -d $(echo ${dir} | sed "s@~@${HOME}@") ]] || incorrent="${incorrent}${dir}\n"
    done
    [[ -n ${incorrent} ]] && message="${message}\e[31;1m[Not directories]\e[m\n${incorrent}" && incorrent=''

    local alias
    # 別名に/が含まれているか
    for alias in $(cat ${saved_dirs} | cut -d' ' -f2 | sort | uniq); do
      [[ ${alias} =~ '/' ]] && incorrent="${incorrent}${alias}\n"
    done
    [[ -n ${incorrent} ]] && message="${message}\e[31;1m[Alias contains \"/\"]\e[m\n${incorrent}"
    [[ -n ${message} ]] && echo -e ${message} | sed '/^$/d' >&2 && print -z 'cds -e'
  }

  case ${action} in
    'change' )
      if [[ -n ${alias} ]]; then
        dir=$(echo ${file} | grep "^${alias} " | head -1) \
      else
        type fzf > /dev/null 2>&1 || return 1
        dir=$(echo ${file} | fzf --header='change directory' --preview='tree -C {}' --preview-window='right:hidden' --bind='ctrl-v:toggle-preview')
      fi
      [[ -n ${dir} ]] && eval cd $(echo ${dir} | cut -d' ' -f2)
    ;;
    'save' )
      [[ ${alias} =~ '/' ]] && echo 'alias: / cannot be used' >&2 && return 1
      alias_exists ${alias} || return 1
      [[ -d ${dir} ]] && dir=$(readlink -f ${dir}) || dir=$(pwd)
      directory_exists ${dir} || return 1
      echo "${tag:-default} ${alias} $(echo ${dir} | sed "s@${HOME}@~@")" >> ${saved_dirs}
    ;;
    'list' )
      [[ -z ${tag} ]] \
        && cat ${saved_dirs} | sort | xargs printf '\e[36m%s\e[m \e[37;1m%s\e[m \e[37m%s\e[m\n' \
        || echo ${file} | sort | xargs printf '\e[37;1m%s\e[m \e[37m%s\e[m\n'
    ;;
    'delete' )
      if [[ -z ${alias} ]]; then
        type fzf > /dev/null 2>&1 || return 1
        alias=$(echo ${file} \
          | fzf --header='delete directory in the record' --preview='tree -C {}' --preview-window='right:hidden' --bind='ctrl-v:toggle-preview' \
          | cut -d' ' -f1)
      fi
      sed -i "/ ${alias} /d" ${saved_dirs}
    ;;
    'delete-all' )
      echo 'delete all?'
      select input in 'no' 'yes'; do
        case ${input} in
          'no' ) break ;;
          'yes' ) : >! ${saved_dirs} && break ;;
        esac
      done
    ;;
    'edit' )
      ${EDITOR} ${saved_dirs}
      check_file
    ;;
    'help' )
      echo '
      cds [別名]
      引数に別名を指定することで、移動する。
      引数を指定しない場合は、filterで選択する。

      -s 記録
      |   cds -s [別名] [path]
      |   pathの指定がなければ$(pwd)とする。別名の指定がなければカレントディレクトリ名とする。

      -l 一覧を出力

      -e 記録を直接編集

      -d 記録を削除
      |   cds -d [別名]
      |   引数を指定しない場合は、filterで選択する。

      --delete-all 全ての履歴を削除

      -t タグ
      |   保存するpathに対してtagを付けられる。
      ' | sed 's/^ *//;s/|/ /'
    ;;
  esac
}

function _cds() {
  [[ -n ${ZDOTDIR} ]] && local file=${ZDOTDIR}/.saved_dirs || local file=${HOME}/.saved_dirs

  _arguments \
    '-s[save]: :->t' \
    '-l[list]: :->t' \
    '-e[edit]: :->none' \
    '-d[delete]: :->alias' \
    '--delete-all[delete all]: :->none' \
    '-t[tag]: :->tag' \
    '-h[help]: :->none' \
    '*: :->alias'

  case ${state} in
    t )
      _arguments '-t[tag]: :->tag'
    ;;
    tag )
      _values 'tags' $(cat ${file} | cut -d' ' -f1 | sort | uniq)
    ;;
    alias )
      _values 'aliases' $(cat ${file} | cut -d' ' -f2-3 | sed 's/ /[/;s/$/]/')
    ;;
  esac
}
compdef _cds cds


function dtr() { # 電源を入れてからのネットワークのデータ転送量を表示。
  cat /proc/net/dev | awk \
    '{if(match($0, /wlp4s0/)!=0) print "Wifi        : Receive",$2/(1024*1024),"MB","|","Transmit",$10/(1024*1024),"MB"} \
    {if(match($0, /bnep0/)!=0) print "Bluetooth Tethering : Receive",$2/(1024*1024),"MB","|","Transmit",$10/(1024*1024),"MB"}'
}

function mt() {
  typeset -r trash="${HOME}/.Trash"
  local fzf_option="--preview-window='right:hidden' --bind='ctrl-v:toggle-preview'"

  ! type fzf > /dev/null 2>&1 && [[ -e ${GOPATH}/bin/mt ]] && ${GOPATH}/bin/mt $@

  case $1 in
    'move')
      [[ -z $2 ]] && set 'move' $(command ls -A ./ | sed "/^${trash##*/}$/"d \
        | eval "fzf --header='move files in the current directory to the trash' \
        --preview=\"file {} | sed 's/^.*: //'; du -hs {} | cut -f1; less {}\" ${fzf_option}") \
        > /dev/null && [[ -z $2 ]] && return
    ;;
    'restore')
      [[ -z $2 ]] && set 'restore' $(command ls -rA ${trash} \
        | eval "fzf --header='move files in the trash to the current directory' \
        --preview=\"file ${trash}/{} | sed 's/^.*: //'; du -hs ${trash}/{} | cut -f1; echo '\n'; less ${trash}/{}\" ${fzf_option}") \
        > /dev/null && [[ -z $2 ]] && return
    ;;
    'delete')
      [[ -z $2 ]] && set 'delete' $(command ls -rA ${trash} \
        | eval "fzf --header='delete files in the trash' \
        --preview=\"file ${trash}/{} | sed 's/^.*: //'; du -hs ${trash}/{} | cut -f1; echo '\n'; less ${trash}/{}\" ${fzf_option}") \
        > /dev/null && [[ -z $2 ]] && return
    ;;
    *)
    ;;
  esac

  [[ -e ${GOPATH}/bin/mt ]] && ${GOPATH}/bin/mt $@
}

function _mt() {
  typeset -r trash="${HOME}/.Trash"
  local ret=1

  function sub_commands() {
    local -a _c

    _c=(
      'move' \
      'restore' \
      'list' \
      'size' \
      'delete'
    )

    _describe -t commands Commands _c
  }

  _arguments -C \
    '(-h --help)'{-h,--help}'[show help]' \
    '1: :sub_commands' \
    '*:: :->args' \
    && ret=0

  case ${state} in
    (args)
      case ${words[1]} in
        (move)
          _files
        ;;
        (restore)
          _values \
            'files in trash' \
            $(command ls -Ar ${trash})
        ;;
        (list)
          _arguments \
            '(-d --days)'{-d,--days}'[How many days ago]' \
            '(-r --reverse)'{-r,--reverse}'[display in reverse order]'
        ;;
        (size)
        ;;
        (delete)
          _values \
            'files in trash' \
            $(command ls -Ar ${trash})
        ;;
      esac
  esac

  return ret
}
compdef _mt mt

function interactive() { # 引数に指定したコマンドを実行するのに確認をとる。
  local input
  while [[ ${input} != 'yes' && ${input} != 'no' ]]; do
    printf '\ryes / no'
    read -s input
  done

  [[ ${input} == 'yes' ]] && command $@
}

function os() { # OSとKernelの情報を表示 (hostnamectl statusで表示できた)
  echo -n 'OS\t'
  uname -o | tr -d '\n'
  cat /etc/os-release | sed '/^PRETTY_NAME/!d;s/.*"\(.*\)".*/(\1)/'
  uname -sr | sed 's/\(.*\) \(.*\)/Kernel\t\1(\2)/'
}

function bat() { # 電池残量
  typeset -r bat='/sys/class/power_supply/BAT1'
  [[ -e ${bat} ]] && cat "${bat}/capacity" | sed 's/$/%/' || echo 'No Battery'
}

function bak() { # ファイルのバックアップをとる
  local file

  if [[ $1 == '-r' ]]; then # .bakを取り除く
    for file in $argv[2,-1]; do
      mv -i ${file}  ${file%.bak}
    done
  else # ファイル名の末尾に.bakをつけた複製を作成する
    for file in $@; do
      eval cp -ir "${file}{,.bak}"
    done
  fi
}

function init_test() {
  [[ -e ./test.sh ]] && return 1
  echo '#!/usr/bin/bash\n' > ./test.sh
  chmod +x ./test.sh
}

# bluetoothテザリング。
# anacondaのdbus-sendを使わないようにする。AC_CF_85_B7_9D_9Aはスマホのmacアドレス。
function bt() {
  typeset -r ADDR='AC:CF:85:B7:9D:9A'

  [[ $(systemctl is-active bluetooth) == 'inactive' ]] && sudo systemctl start bluetooth.service
  () {
    echo 'power on' \
      && sleep 1 \
      && echo "connect $1" \
      && sleep 3 \
      && echo 'quit'
  } ${ADDR} | bluetoothctl
  /usr/bin/dbus-send --system --type=method_call --dest=org.bluez /org/bluez/hci0/dev_${ADDR//:/_} org.bluez.Network1.Connect string:'nap'
  sudo dhcpcd bnep0
}

function fin() { # コマンドが終了したことを知らせる(ex: command ; fin)
  type i3-nagbar > /dev/null 2>&1 && i3-nagbar -t warning -m 'finish' -f 'pango:IPAGothic Regular 10' > /dev/null 2>&1
}

# コマンドの終了ステータスを見てファイルに記録するか否かを決めたいので、
# ここではファイルには記録しない。
# 0 記録する, 1 記録しない, 2 メモリにだけ記録する
function _record_cmd() {
  typeset -g _cmd=${1%%$'\n'}
  return 2
}
add-zsh-hook zshaddhistory _record_cmd

function _save_cmd() {
  local exit_status="$?"
  #_cmd=$(echo ${_cmd} | tr -s ' ') # 連続する空白を1つにする; sed /  */ で連続する空白を使う
  [[ ! ${_cmd} =~ ' ' ]] && return # 引数やオプションを指定していない場合は記録しない
  [[ ${_cmd} =~ '^ ' ]] && return

  # 履歴に記録しないコマンドを記述
  local ignore_cmds=(\
    cds up mt md gcm gco gaf ll \
    ls cd mv cp rm mkdir rmdir touch man less history source '\.' export type which file stat \
    vi vim sudoedit command builtin chromium unzip tree test '\[' '\[\[' \
    nvim code python go \
  )

  local ignore_cmd
  for ignore_cmd in ${ignore_cmds}; do
    [[ ${_cmd} =~ "^${ignore_cmd}" ]] && return
  done
  # コマンドが正常終了した場合はファイルに記録する
  [[ ${exit_status} == 0 ]] && print -sr -- "${_cmd}"
}
add-zsh-hook precmd _save_cmd

function crypt() {
  # crypt test.txt
  # ファイルの暗号と復号を行う。暗号か復号はファイルの状態で自動で決める。

  ! type openssl > /dev/null 2>&1 && echo 'require openssl' && return 1

  if [[ $(file $1 | cut -d' ' -f2-) == "openssl enc'd data with salted password" ]]; then
    local password
    while [[ -z ${password} ]]; do
      printf '\rpassword:'
      read password
    done
    openssl enc -d -aes-256-cbc -salt -k ${password} -in $1 -out ${1%.enc}
    command rm $1
  else
    local password1
    while [[ -z ${password1} ]]; do
      printf '\rpassword:'
      read password1
    done
    local password2
    while [[ -z ${password2} ]]; do
      printf '\rretype password:'
      read password2
    done
    [[ ${password1} != ${password2} ]] && tput dl1 && echo '\rfailed' && return 1
    openssl enc -e -aes-256-cbc -salt -k ${password1} -in $1 -out $1.enc
    command rm $1
  fi
  # tput dl1
}
function _crypt() {
  _files
}
compdef _crypt crypt

function md() { # マルチディスプレイ
  type xrandr > /dev/null 2>&1 || return 1
  if [[ $1 == 'school' ]]; then
    xrandr --output HDMI1 --left-of eDP1 --mode 1600x900
  elif [[ $1 == 'home' ]]; then
    xrandr --output HDMI1 --left-of eDP1 --mode 1366x768
  elif [[ $1 == 'off' ]]; then
    xrandr --output $(xrandr | grep ' connected' | grep -v 'primary' | cut -d' ' -f1) --off
  elif [[ $1 == 'select' ]]; then
    type fzf > /dev/null 2>&1 || return 1
    xrandr --output ${2:-VGA1} --left-of eDP1 --mode $(xrandr | sed -n '/.* connected [^p].*/,/^[^ ]/p' | sed '1d;$d;s/  */ /g' | cut -d' ' -f2 | fzf)
  fi
}
function _md() {
  _values \
    'args' \
    'school' \
    'home' \
    'off' \
    'select' \
}
compdef _md md

function rs() { # ファイル名から空白を除去
  for file in $@; do
    [[ -e ${file} && ${file} =~ ' ' ]] && mv ${file} $(echo ${file} | sed 's/ //g')
  done
}

function rn() { # ファイル名を正規表現で変更する。perl製のrenameような。
  for i in {2..$#}; do
    local new=$(echo ${argv[${i}]} | sed ${1})
    [[ -e ${argv[${i}]} && ${argv[${i}]} != ${new} ]] && mv ${argv[${i}]} ${new}
  done
}

function cc() { # ファイルの文字数を数える
  [[ -s $1 ]] && cat $1 | sed ':l;N;$!b l;s/\n//g' | wc -m
}

function ga() { # git add をfilterで選択して行う。<C-v>でgit diffを表示。
  type git > /dev/null 2>&1 || return 1
  git status > /dev/null 2>&1 || return 1

  local file unadded_files

  for file in "${(f)$(git status --short)}"; do
    local header=$(echo ${file} | cut -c1-2)
    [[ ${header} == '??' || ${header} =~ '( |M|A|R|U)(M|U)' ]] && unadded_files="${unadded_files}\n$(echo ${file} | cut -c4-)"
  done
  local selected_files=$(echo ${unadded_files} | sed /^$/d \
    | fzf --preview='git diff --color=always {}' --preview-window='right:95%:hidden' --bind='ctrl-v:toggle-preview')
  [[ -n ${selected_files} ]] && git add $(echo ${selected_files} | sed ':l;N;$!b l;s/\n/ /g')
}

function gcm() { # commit message 記しやすい
  type git > /dev/null 2>&1 || return 1
  git status > /dev/null 2>&1 || return 1
  [[ $# -eq 0 ]] && return 1

  git commit -m "$1"
}

function gco() { # git checkout の引数をfilterで選択する
  type git > /dev/null 2>&1 || return 1
  git status > /dev/null 2>&1 || return 1

  local branch=$(git branch | tr -d ' ' | sed /^\*/d | fzf)
  [[ -n ${branch} ]] && git checkout ${branch}
}

function gp() { # git push
  type git > /dev/null 2>&1 || return 1
  git status > /dev/null 2>&1 || return 1

  git push origin ${1:-master}
}

function gmv() { # git mv
  type git > /dev/null 2>&1 || return 1
  git status > /dev/null 2>&1 || return 1
  [[ $# -eq 0 ]] && return 1

  [[ ${argv[$(expr $# - 1)]} != '-t' ]] && return 1
  local target=${argv[$#]}
  for i in {1..$(expr $# - 2)}; do
    git mv ${argv[$i]} ${target}
  done
}

function is_docker_running() { # docker daemonが起動しているか
  docker info > /dev/null 2>&1 && return 0
  echo 'Is the docker daemon running?'
  print -z 'sudo systemctl start docker'

  return 1
}

function jwm() { # dockerでjwmを動かす。chromiumのデータを復号・暗号
  is_docker_running || return

  local passwd && printf '\rpassword:' && read -s passwd
  [[ -e /tmp/.X11-unix/X1 ]] && local exists='true' || Xephyr -wr -resizeable :1 > /dev/null 2>&1 &

  local workdir="${HOME}/workspace/docker/ubuntu-jwm"
  local chrome="${workdir}/google-chrome"

  # 復号
  [[ -e "${chrome}.tar.enc" ]] && type openssl > /dev/null 2>&1 \
    && openssl enc -d -aes-256-cbc -salt -k ${passwd} -in "${chrome}.tar.enc" -out "${chrome}.tar" \
    && command rm "${chrome}.tar.enc" || return 1
  # 展開
  [[ -e "${chrome}.tar" ]] && tar -xf "${chrome}.tar" -C ${workdir} && command rm "${chrome}.tar"

  docker run $@ \
    -v ${workdir}/data:/home/docker/data \
    -v ${chrome}:/home/docker/.config/google-chrome \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v /run/user/${UID}/pulse/native:/tmp/pulse/native \
    -v ${HOME}/.config/pulse/cookie:/tmp/pulse/cookie \
    -it --rm ${USER}/ubuntu-jwm > /dev/null 2>&1

  [[ -z ${exists} ]] && pkill Xephyr > /dev/null 2>&1
  # 書庫化
  [[ -e ${chrome} ]] && tar -cf "${chrome}.tar" -C ${workdir} $(basename ${chrome}) && command rm -r ${chrome}
  # 暗号
  [[ -e "${chrome}.tar" ]] && type openssl > /dev/null 2>&1 \
    && openssl enc -e -aes-256-cbc -salt -k ${passwd} -in "${chrome}.tar" -out "${chrome}.tar.enc" \
    && command rm "${chrome}.tar"
}

function drm() { # dockerのコンテナを選択して破棄
  is_docker_running && type fzf > /dev/null 2>&1 && typeset -r container=$(docker ps -a | sed 1d | fzf --header="$(docker ps -a | sed -n 1p)")
  [[ -n ${container} ]] && echo ${container} | tr -s ' ' | cut -d' ' -f1 | xargs docker rm
}

function drmi() { # dockerのimageを選択して破棄
  is_docker_running && type fzf > /dev/null 2>&1 && typeset -r image=$(docker images | sed 1d | fzf --header="$(docker images | sed -n 1p)")
  [[ -n ${image} ]] && echo ${image} | tr -s ' ' | cut -d' ' -f3 | xargs docker rmi
}

function dc() {
  is_docker_running && docker-compose $@
}

function rp() {
  echo 'pi@192.168.3.16'
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

  case ${state} in
    (args)
      case ${words[1]} in
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

function second() {
  local second=${GOPATH}/bin/second
  [[ $1 == 'change' ]] \
    && cd $(${second} $@ || echo '.') \
    || ${second} $@
}
alias sc='second'

# =========================================================================
# alias
# =========================================================================
alias la='ls -A --color=auto'
alias ll='ls -FAlht --color=auto'
alias grep='grep -i --color=auto'
# alias mv='mv -i' alias cp='cp -i'
alias ln='ln -i'
alias rm='echo "zsh: command not found: rm"'
alias mkdir='mkdir -vp'
alias free='free -wh'
alias du='du -h'
alias df='df -hT'
alias ip='ip -c'
alias nano='nano -$ -l -i -O -m -c' # オブションは個々に指定してないと効かない
alias tree='tree -C'
alias xbg="xbacklight -get | xargs printf '%.0f%%\n'"
alias xephyr='Xephyr -wr -resizeable :1' # x serverのネスト。白背景。window可変。
alias open='xdg-open'
alias crm='chromium'
alias noise='paplay /usr/share/sounds/alsa/Noise.wav'
alias poweroff='interactive systemctl poweroff'
alias reboot='interactive systemctl reboot'
alias logout='interactive i3-msg exit'
alias -g @g='| grep'
alias -g @l='| less'
alias -g @j='| jq'
alias -g ..2='../..'
alias -g ..3='../../..'
alias -g lf='$(ls | fzf)'
alias -g laf='$(ls -A | fzf)'
alias -s txt=less
alias -s {html,md,pdf}=chromium
alias -s {png,jpg}=feh
alias -s {mp3}=paplay
alias -s py=python3
