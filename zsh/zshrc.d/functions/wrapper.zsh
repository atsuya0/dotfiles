function vim() { # Choose files to open by fzf.
  function editor() {
    if [[ -n ${commands[nvim]} ]]; then
      echo "nvim $@"
    elif [[ -n ${commands[vim]} ]]; then
      echo "vim $@"
    else
      echo "vi $@"
    fi
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
      && local -r files=$(choice $1) \
      || { eval $(editor $@); return 0; }
    [[ -n ${files} ]] && { eval $(editor ${files}); return 0; }
    return 1
  fi

  [[ -z ${commands[fzf]} ]] && return 1
  local -r files=$(choice)
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
  # google search
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

function scrot() { # screenshot
  local -r dir="${HOME}/contents/pictures/screenshot/"
  [[ -d ${dir} ]] || mkdir -p ${dir}

  command scrot $1 -q 100 '%Y-%m-%d_%H:%M:%S.png' \
    -e "mv \$f ${dir}"
}
