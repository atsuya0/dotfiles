function is_managed() {
  type git &> /dev/null || return 1
  git status > /dev/null 2>&1 || return 1
}

function gaf() { # git add をfilterで選択して行う。<C-v>でgit diffを表示。
  is_managed || return 1

  local file
  for file in "${(f)$(git status --short)}"; do
    local header=$(echo ${file} | cut -c1-2)
    [[ ${header} == '??' || ${header} =~ '( |M|A|R|U)(M|U)' ]] \
      && local unadded_files="${unadded_files}\n$(echo ${file} | rev | cut -d' ' -f1 | rev)" \
      || local unadded_files
  done
  local selected_files=$(echo ${unadded_files} | sed /^$/d \
    | fzf --preview='git diff --color=always {}' --preview-window='right:95%:hidden' --bind='ctrl-v:toggle-preview')
  [[ -n ${selected_files} ]] && git add $(echo ${selected_files} | sed ':l;N;$!b l;s/\n/ /g')
}

function gcof() { # git checkout の引数をfilterで選択する
  is_managed || return 1
  type fzf > /dev/null 2>&1 || return 1

  typeset -r branch=$(git branch | tr -d ' ' | sed /^\*/d | fzf)
  [[ -n ${branch} ]] && git checkout "${branch}"
}

function gmv() { # git mv
  is_managed || return 1
  [[ $# -ne 0 ]] || return 1
  [[ ${argv[$(expr $# - 1)]} == '-t' ]] || return 1

  typeset -r target=${argv[$#]}
  for i in {1..$(expr $# - 2)}; do
    git mv "${argv[$i]}" "${target}"
  done
}


alias gb='git branch'
alias gs='git status'
alias gd='git diff'
alias gl='git log'
alias ga='git add'
alias gcm='git commit -m'
alias gco='git checkout'
alias gph='git push origin'
alias gpl='git pull origin'

alias -g gls='$(git status --short | cut -c 4- | fzf)'
