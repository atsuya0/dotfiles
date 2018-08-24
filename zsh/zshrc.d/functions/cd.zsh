# 親階層に移動する
# up 2    -> cd ../..
# up      -> filterを使って選択する
function up() {
  local str

  if [[ $# -eq 0 ]] && type fzf > /dev/null 2>&1; then
    str=$(pwd | sed ':a;s@/[^/]*$@@;p;/^\/[^/]*$/!ba;d' \
      | fzf --preview='tree -C {}' --preview-window='right:hidden' --bind='ctrl-v:toggle-preview')
  elif expr ${1-dummy} + 1 > /dev/null 2>&1; then
    str=$(seq -s: $1 | sed 's/://g;s@.@\.\./@g')
  else
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
  [[ ${#pwd} -gt 2 ]] && echo "${pwd}" >> "${_CD_FILE}"
}
add-zsh-hook chpwd _save_pwd

function cdh() { # 移動履歴からfilterを使って選んでcd
  local dir

  case $1 in
    '-l' ) cat "${_CD_FILE}" | sort | uniq -c | sort -r | tr -s ' ' ;; # 記録一覧
    '--delete-all' ) : > "${_CD_FILE}" ;; # 記録の全消去
    '-d' ) # 記録の消去
      type fzf > /dev/null 2>&1 || return 1

      local opt
      [[ ${OSTYPE} == darwin* ]] && opt='' # BSDのsedの場合は-iに引数(バックアップファイル名)を取る
      cat "${_CD_FILE}" \
        | fzf --header='delete directory in the record' --preview='tree -C {}' --preview-window='right:hidden' --bind='ctrl-v:toggle-preview' \
        | xargs -I{} sed -i "${opt}" 's@^{}$@@;/^$/d' "${_CD_FILE}"
    ;;
    * ) # 記録しているディレクトリを表示 使用頻度順
      if [[ $# -eq 0 ]]; then
        type fzf > /dev/null 2>&1 || return 1
        dir=$(cat ${_CD_FILE} | sort | uniq -c | sort -r | tr -s ' ' | cut -d' ' -f3 \
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
      $(cat ${_CD_FILE} | sort | uniq -c | sort -r | awk '{print $2}')
  }
  _arguments \
    '-l[list]' \
    '-d[delete]' \
    '--delete-all[delete all]' \
    '1: :visited'
}
compdef _cdh cdh

function second() {
  local second="${GOPATH}/bin/second"
  [[ $1 == 'change' ]] \
    && cd "$(${second} $@ || echo '.')" \
    || "${second}" $@
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

  case "${state}" in
    (args)
      case "${words[1]}" in
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

alias sc='second'
