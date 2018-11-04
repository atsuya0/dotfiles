function is_managed() {
  type git &> /dev/null || return 1
  git status > /dev/null 2>&1 || return 1
}

function ga() { # git add をfilterで選択して行う。<C-v>でgit diffを表示。
  is_managed || return 1

  local file unadded_files

  for file in "${(f)$(git status --short)}"; do
    local header=$(echo ${file} | cut -c1-2)
    [[ ${header} == '??' || ${header} =~ '( |M|A|R|U)(M|U)' ]] \
      && unadded_files="${unadded_files}\n$(echo ${file} | rev | cut -d' ' -f1 | rev)"
  done
  local selected_files=$(echo ${unadded_files} | sed /^$/d \
    | fzf --preview='git diff --color=always {}' --preview-window='right:95%:hidden' --bind='ctrl-v:toggle-preview')
  [[ -n ${selected_files} ]] && git add $(echo ${selected_files} | sed ':l;N;$!b l;s/\n/ /g')
}

function gcm() { # commit message 記しやすい
  is_managed || return 1
  [[ $# -ne 0 ]] || return 1

  git commit -m $1
}

function gco() { # git checkout の引数をfilterで選択する
  is_managed || return 1
  type fzf > /dev/null 2>&1 || return 1

  local branch=$(git branch | tr -d ' ' | sed /^\*/d | fzf)
  [[ -n ${branch} ]] && git checkout "${branch}"
}

function gp() { # git push
  is_managed || return 1
  git push origin "${1:-master}"
}

function gmv() { # git mv
  is_managed || return 1
  [[ $# -ne 0 ]] || return 1
  [[ ${argv[$(expr $# - 1)]} == '-t' ]] || return 1

  local target=${argv[$#]}
  for i in {1..$(expr $# - 2)}; do
    git mv "${argv[$i]}" "${target}"
  done
}

function gl() {
  local -a subcmds=(
    'branch'
    'branch --all'
    'branch -m'
    'branch -d'
    'checkout'
    'remote -v'
    'remote add origin https://github.com/'
    'status'
    'add'
    'commit -m'
    'commit --amend'
    'push origin'
    'log'
    'log --merges'
    'log --no-merges'
    'log --online'
    'reflog'
    'reset'
    'reset --soft'
    'reset --mixed'
    'reset --hard'
  )

  function print_array() {
    local subcmd
    for subcmd in ${@}; do
      echo ${subcmd}
    done
  }

  local subcmd=$(print_array ${subcmds} | fzf)
  [[ -n ${subcmd} ]] && print -z git ${subcmd}
}
