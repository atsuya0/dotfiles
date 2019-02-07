function is_managed_by_git() {
  [[ -z ${commands[git]} ]] && return 1
  git status &> /dev/null || return 1
}

function fga() { # git add をfilterで選択して行う。<C-v>でgit diffを表示。
  is_managed_by_git || return 1

  local file unadded_files
  for file in "${(f)$(git status --short)}"; do
    local header=$(echo ${file} | cut -c1-2)
    [[ ${header} == '??' || ${header} =~ '( |M|A|R|U)(M|U)' ]] \
      && local unadded_files="${unadded_files}\n$(echo ${file} | rev | cut -d' ' -f1 | rev)"
  done
  local selected_files=$(echo ${unadded_files} | sed /^$/d \
    | fzf --preview='git diff --color=always {}' --preview-window='right:95%:hidden' --bind='ctrl-v:toggle-preview')
  [[ -n ${selected_files} ]] && git add $@ $(echo ${selected_files} | tr '\n' ' ')
}

function fgco() { # git checkout の引数をfilterで選択する
  is_managed_by_git || return 1
  [[ -z ${commands[fzf]} ]] && return 1

  local -r branch=$(git branch | tr -d ' ' | sed /^\*/d | fzf)
  [[ -n ${branch} ]] && git checkout "${branch}"
}

function gmv() { # git mv
  is_managed_by_git || return 1
  [[ $# -ne 0 ]] || return 1
  [[ ${argv[$(expr $# - 1)]} == '-t' ]] || return 1

  local -r target=${argv[$#]}
  for i in {1..$(expr $# - 2)}; do
    git mv "${argv[$i]}" "${target}"
  done
}

function gu() {
  is_managed_by_git || return 1
  xdg-open $(git config --get remote.origin.url)
}

function __git_branch_list__() {
  is_managed_by_git || return 1
  git branch | grep -v "^*" | tr -d " " | fzf
}

function __git_working_tree_status__() {
  is_managed_by_git || return 1
  git status --porcelain | grep '^.M' \
    | cut -c 4- \
    | fzf --preview='git diff --color=always {}' \
      --preview-window='right:95%:hidden' \
      --bind='ctrl-v:toggle-preview'
}

alias gb='git branch'
alias gs='git status'
alias gd='git diff'
alias gdc='git diff --cached'
alias gl='git log'
alias ga='git add'
alias gcm='git commit -m'
alias gco='git checkout'
alias gph='git push origin'
alias gpl='git pull origin'

alias -g @gb='$(__git_branch_list__)'
alias -g @gw='$(__git_working_tree_status__)'
