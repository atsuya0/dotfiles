function print_parents() {
  pwd | sed '/[^\/]$/s@$@/@;:a;s@[^/]\+/$@@;p;/^\/$/!ba;d'
}

# pwd | shorten_path
function shorten_path() {
  while read -r line; do
    sed "s@\([^/]\{${1:-1}\}\)[^/]*/@\1/@g" <<< ${line}
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
