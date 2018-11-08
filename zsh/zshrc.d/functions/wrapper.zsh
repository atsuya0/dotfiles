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
    && command scrot -u -q 100 '%Y-%m-%d_%H:%M:%S.png' -e '[[ -d ~/Content/pictures/screenshot/ ]] && mv $f ~/Content/pictures/screenshot/' \
    || command scrot $@
}
