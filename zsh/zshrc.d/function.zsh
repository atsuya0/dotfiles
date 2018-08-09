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
