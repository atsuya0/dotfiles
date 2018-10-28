function ls() { # 何も表示されないならば隠しファイルの表示を試みる。
  [[ $(command ls $@ 2> /dev/null) == '' ]] \
    && command ls -FA --color=auto $@ 2> /dev/null \
    || command ls -F --color=auto $@
}

# 良い関数名が思いつかなかった
function __mcvp__() {
  # 引数が指定されていないなら選択的インターフェースで選択する
  # 1回目の選択でコピー元を選択する。複数選択可。
  # 2回目でコピー先を選択する。ヘッダにコピー元のファイル・ディレクトリが表示される。

  [[ $# -ne 1 ]] && return 1
  local cmd=$1

  local dir
  for dir in ${ignore_absolute_pathes}; do
    local argument="${argument} -path ${dir/$(pwd)/.} -prune -o"
  done
  local fzf_options="--select-1 \
    --preview='tree -c {} | head -200' \
    --preview-window='right:hidden' \
    --bind='ctrl-v:toggle-preview'"

  # 元
  local source=($(eval find -mindepth 1 ${argument} -print 2> /dev/null \
    | cut -c3- | eval fzf ${fzf_options}))

  [[ ${#source[@]} -eq 0 ]] && return

  # 宛先
  local destination=$(eval find -mindepth 1 ${argument} -print 2> /dev/null \
    | cut -c3- | eval fzf --header="'${source[@]}'" ${fzf_options})

  [[ -n ${destination} ]] && eval ${cmd} ${source[@]} -t ${destination}
}

function cp() {
  [[ $# -ne 0 ]] && { command cp -iv $@; return ;}
  __mcvp__ 'cp -riv'
}

function mv() {
  [[ $# -ne 0 ]] && { command mv -iv $@; return ;}
  __mcvp__ 'mv -iv'
}

function mount() {
  # fat32なら現在のユーザで弄れるようにする
  # ディレクトリを省略すると~/mntにマウントする

  [[ $# -eq 0 ]] && { command mount; return ;}

  local mnt="${HOME}/mnt"
  [[ $# -eq 1 ]] && mkdir ${mnt} && set $1 ${mnt}

  [[ $(sudo file -s $1 | cut -d' ' -f2) == 'DOS/MBR' ]] \
    && sudo \mount -o uid=$(id -u),gid=$(id -g) $1 $2 \
    || sudo \mount $1 $2
}

function umount() {
  [[ $# -ne 0 ]] \
    && { command umount $@; return ;}

  local mnt="${HOME}/mnt"
  [[ -d ${mnt} ]] || return 1
  sudo \umount ${mnt} || return 1
  rmdir ${mnt}
}

function history() { # historyの実行時に引数を指定しないなら全ての履歴を表示。
  [[ $# -eq 0 ]] \
    && builtin history -i 1 \
    || builtin history $@
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

  [[ $# -ne 0 ]] && { command ${editor} $@; return ;}
  type fzf &> /dev/null || { command ${editor} $@; return ;}

  # 無視するディレクトリ(絶対path指定)
  local args dir
  for dir in ${ignore_absolute_pathes}; do
    args="${args} -path ${dir/$(pwd)/.} -prune -o"
  done
  # 無視する拡張子
  local ignore_filetypes=( pdf png jpg jpeg mp3 mp4 tar.gz zip )
  local ftype
  for ftype in ${ignore_filetypes}; do
    args="${args} -path "\'\*${ftype}\'" -prune -o"
  done

  # 無視するディレクトリ(ディレクトリ名指定)
  local ignore_dirs=(
    .git node_modules vendor target gems cache google-chrome
  )
  for dir in ${ignore_dirs}; do
    args="${args} -path "\'\*${dir}\*\'" -prune -o"
  done

  local file=$(eval find ${args} -type f -print | cut -c3- \
    | fzf --select-1 --preview='less {}' --preview-window='right:hidden' --bind='ctrl-v:toggle-preview')
  [[ -n ${file} ]] && command "${editor}" "${file}"
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
    && command scrot -u -q 100 '%Y-%m-%d_%H:%M:%S.png' -e '[[ -d ~/Content/pictures/screenshot/ ]] && mv $f ~/Content/pictures/screenshot/' \
    || command scrot $@
}
