function vim() { # Choose files to open by fzf.
  function editor() {
    if cmd_exists 'nvim'; then
      echo "nvim $@"
    elif cmd_exists 'vim'; then
      echo "vim $@"
    else
      echo "vi $@"
    fi
  }

  function ignore_filetypes() {
    typeset -r ignore_filetypes=(
      pdf png jpg jpeg mp3 mp4 tar.gz zip
    )
    local filetype
    for filetype in ${ignore_filetypes}; do
      echo '-name' "\*${filetype}" '-prune -o'
    done
  }

  function ignore_dirs() {
    typeset -r ignore_dirs=(
      .git
      node_modules # node.js
      vendor # golang
      target # rust
      gems # ruby
      db/data # docker
    )
    local dir
    for dir in ${ignore_dirs}; do
      echo '-path' "\*${dir}\*" '-prune -o'
    done
  }

  function choice() {
    eval find ${1:-.} \
      $(ignore_filetypes) $(ignore_dirs) $(ignore_absolute_paths) \
      -type f -print \
      | fzf --select-1 --preview='less {}' \
        --preview-window='right:hidden' --bind='ctrl-v:toggle-preview'
  }

  if [[ $# -ne 0 ]]; then
    [[ -d $1 ]] \
      && typeset -r files=$(choice $1) \
      || { eval $(editor $@); return 0; }
    [[ -n ${files} ]] && eval $(editor ${files}) ; return 0
    return 1
  fi

  type fzf &> /dev/null || return 1
  typeset -r files=$(choice)
  [[ -n ${files} ]] && eval $(editor ${files})
}

function ls() { # 何も表示されないならば隠しファイルの表示を試みる。
  [[ $(command ls $@ 2> /dev/null) == '' ]] \
    && command ls -FA --color=auto $@ 2> /dev/null \
    || command ls -F --color=auto $@
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
    && command scrot -u -q 100 '%Y-%m-%d_%H:%M:%S.png' \
      -e '[[ -d ~/Content/pictures/screenshot/ ]] && mv $f ~/Content/pictures/screenshot/' \
    || command scrot $@
}
