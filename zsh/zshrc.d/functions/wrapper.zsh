function bash() { # bash終了時に.bash_historyを削除する。
  cmd_exists bash || return
  command bash
  trap "command rm ${HOME}/.bash_history" EXIT
}

function ls() { # 何も表示されないならば隠しファイルの表示を試みる。
  [[ $(command ls $@) == '' ]] \
    && command ls -FA --color=auto $@ \
    || command ls -F --color=auto $@
}

function cp() {
  # 引数が指定されていないなら選択的インターフェースで選択する
  # 1回目の選択でコピー元を選択する。複数選択可。
  # 2回目でコピー先を選択する。ヘッダにコピー元のファイル・ディレクトリが表示される。

  [[ $# -ne 0 ]] && command cp -iv $@ && return

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

  [[ -n ${destination} ]] && command cp -riv "${source}" -t "${destination}"
}

function mv() { # cp と同じ
  [[ $# -ne 0 ]] && command mv -iv $@ && return

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

  [[ -n ${destination} ]] && command mv -iv "${source}" -t "${destination}"
}

function mount() {
  # fat32なら現在のユーザで弄れるようにする
  # ディレクトリを省略すると~/mntにマウントする

  [[ $# -eq 0 ]] && command mount && return

  local mnt="${HOME}/mnt"
  [[ -e ${mnt} ]] || mkdir "${mnt}"
  [[ $# -eq 1 ]] && set $1 "${mnt}"

  [[ $(sudo file -s $1 | cut -d' ' -f2) == 'DOS/MBR' ]] \
    && sudo \mount -o uid=$(id -u),gid=$(id -g) $1 $2 \
    || sudo \mount $1 $2
}

function umount() {
  [[ $# -eq 0 ]] \
    && local mnt="${HOME}/mnt" \
    && sudo \umount "${mnt}" \
    && rmdir "${mnt}" \
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

  if [[ $# -eq 0 ]] && type fzf &> /dev/null; then

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
      node_modules .git gems vendor cache google-chrome data_docker-compose
      data-mariadb
    )
    for dir in ${ignore_dirs}; do
      arg="${arg} -path "\'\*${dir}\*\'" -prune -o"
    done

    local file=$(eval find ${arg} -type f -print | cut -c3- \
      | fzf --select-1 --preview='less {}' --preview-window='right:hidden' --bind='ctrl-v:toggle-preview')
    [[ -n ${file} ]] && command "${editor}" "${file}"
  else
    command "${editor}" $@
  fi
}

function urxvt() { # 簡単にフォントサイズを指定して起動する。
  [[ $# -eq 0 ]] && command urxvt $@ && return
  expr $1 + 1 &> /dev/null
  [[ $? -ne 2 ]] && command urxvt --font "xft:Ricty Discord:size=$1"
}

function ranger() { # rangerのサブシェルでネストしないようにする。
  [[ -z ${RANGER_LEVEL} ]] && command ranger $@ || exit
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

    command w3m "${parameter}"
  } || command w3m $@
}

function scrot() { # スクリーンショット
  [[ $# -eq 0 ]] \
    && command scrot -q 100 '%Y-%m-%d_%H:%M:%S.png' -e '[[ -d ~/Content/pictures/screenshot/ ]] && mv $f ~/Content/pictures/screenshot/' \
    || command scrot $@
}
