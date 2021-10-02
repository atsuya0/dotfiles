function print_parents() {
  pwd | sed '/[^\/]$/s@$@/@;:a;s@[^/]\+/$@@;p;/^\/$/!ba;d'
}

# // pwd | shorten_path
function shorten_path() {
  while read -r line; do
    sed 's@\(.\)/$@\1@;s@\([^/]\{1\}\)[^/]*/@\1/@g' <<< ${line}
  done
}

# 親階層に移動する
# up 2    -> cd ../..
# up      -> use filter
function up() {
  if [[ $# -eq 0 ]] \
    && [[ -n ${commands[fzf]} ]] && type print_parents &> /dev/null
  then
    local -r parent_path=$(print_parents \
      | fzf --delimiter='/' --nth='-2' --bind='ctrl-v:toggle-preview' \
          --preview='ls --color=auto {}' --preview-window='right:50%:hidden')
  elif [[ $1 =~ ^[0-9]+$ ]]; then
    local -r parent_path=$(seq -s '' $1 | sed 's@.@\.\./@g')
  else
    local -r parent_path=$1
  fi

  builtin cd ${parent_path:-.}
}

function _up() {
  _values 'parents' $(print_parents)
}
compdef _up up

function down() {
  [[ -z ${commands[fzf]} ]] && return 1

  local -A opthash
  zparseopts -D -A opthash -- d: e

  [[ -n "${opthash[(i)-e]}" ]] \
    && local -r hidden='-name .\* -prune -o'

  [[ "${opthash[-d]}" =~ ^[0-9]+$ ]] \
    && local depth="-maxdepth ${opthash[-d]}" \
    || local depth="-maxdepth 5"

  local dir=$(
    eval find -mindepth 1 $(ignore_dirs) $(ignore_absolute_paths) ${hidden} ${depth} \
      -type d -print 2> /dev/null \
    | cut -c3- \
    | fzf --select-1 --preview='tree -C {} | head -200' \
      --preview-window='right:hidden' --bind='ctrl-v:toggle-preview'
  )
  eval builtin cd ${dir:-.}
}

function _down() {
  function number() {
    _values 'number(default: 5)' $(seq 4)
  }
  _arguments \
    '-d[depth]: :number' \
    '-e[exclude hidden files]'
}
compdef _down down

alias dw='down'

function __save_pwd__() { # 移動履歴をファイルに記録する。~, / は記録しない。
  local -r pwd=$(pwd | sed "s@${HOME}@~@")
  [[ ${#pwd} -gt 2 ]] && echo "${pwd}" >> "${_CD_HISTORY}"
}
add-zsh-hook chpwd __save_pwd__

function cdh() { # 移動履歴からfilterを使って選んでcd
  case $1 in
    '-l' ) cat "${_CD_HISTORY}" | sort | uniq -c | sort -r | tr -s ' ' ;;
    '--delete-all' ) : > "${_CD_HISTORY}" ;;
    '-d' )
      [[ -z ${commands[fzf]} ]] && return 1

      cat "${_CD_HISTORY}" \
        | fzf --header='delete directory in the record' \
            --preview='tree -C {}' --preview-window='right:hidden' \
            --bind='ctrl-v:toggle-preview' \
        | xargs -I{} sed -i 's@^{}$@@;/^$/d' "${_CD_HISTORY}"
    ;;
    * ) # 使用頻度順
      if [[ $# -eq 0 ]]; then
        [[ -z ${commands[fzf]} ]] && return 1

        local dir=$(cat ${_CD_HISTORY} | sort | uniq -c | sort -r | tr -s ' ' | cut -d' ' -f3 \
          | fzf --preview='tree -C {}' --preview-window='right:hidden' --bind='ctrl-v:toggle-preview')
        [[ -z ${dir} ]] && return 1
      fi
      eval cd "${dir:-$1}"
    ;;
  esac
}

function _cdh() {
  function visited() {
    _values 'visited' \
      $(cat ${_CD_HISTORY} | sort | uniq -c | sort -r | awk '{print $2}')
  }
  _arguments \
    '-l[list]' \
    '-d[delete]' \
    '--delete-all[delete all]' \
    '1: :visited'
}
compdef _cdh cdh
