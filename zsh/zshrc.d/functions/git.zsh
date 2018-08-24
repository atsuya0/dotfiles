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

  git commit -m $1
}

function gco() { # git checkout の引数をfilterで選択する
  type git > /dev/null 2>&1 || return 1
  git status > /dev/null 2>&1 || return 1

  local branch=$(git branch | tr -d ' ' | sed /^\*/d | fzf)
  [[ -n ${branch} ]] && git checkout "${branch}"
}

function gp() { # git push
  type git > /dev/null 2>&1 || return 1
  git status > /dev/null 2>&1 || return 1

  git push origin "${1:-master}"
}

function gmv() { # git mv
  type git > /dev/null 2>&1 || return 1
  git status > /dev/null 2>&1 || return 1
  [[ $# -eq 0 ]] && return 1

  [[ ${argv[$(expr $# - 1)]} != '-t' ]] && return 1
  local target=${argv[$#]}
  for i in {1..$(expr $# - 2)}; do
    git mv "${argv[$i]}" "${target}"
  done
}

