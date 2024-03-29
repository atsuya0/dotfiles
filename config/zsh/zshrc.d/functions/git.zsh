function is_managed_by_git() {
  [[ -z ${commands[git]} ]] \
    && { echo 'git is required'; return 1; }
  git status &> /dev/null \
    || { echo "Not managed by git"; return 1; }
}

function fga() { # git add をfilterで選択して行う。<C-v>でgit diffを表示。
  is_managed_by_git || return 1

  local file unadded_files
  for file in "${(f)$(git status --short)}"; do
    local header=$(echo ${file} | cut -c1-2)
    [[ ${header} == '??' || ${header} =~ '( |M|A|R|U)(M|U|D)' ]] \
      && local unadded_files="${unadded_files}\n$(echo ${file} | rev | cut -d' ' -f1 | rev)"
  done
  local selected_files=$(echo ${unadded_files} | sed /^$/d \
    | fzf --preview='git diff --color=always {}' --preview-window='right:95%:hidden' --bind='ctrl-v:toggle-preview')
  [[ -n ${selected_files} ]] && git add $@ $(echo ${selected_files} | tr '\n' ' ')
}

function fgsw() { # git switch の引数をfilterで選択する
  is_managed_by_git || return 1
  [[ -z ${commands[fzf]} ]] && return 1

  local -r branch=$(git branch | tr -d ' ' | sed /^\*/d | fzf)
  [[ -n ${branch} ]] && git switch "${branch}"
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

function gss() {
  is_managed_by_git || return 1

  function filter() {
    git stash list \
      | fzf \
      --header="${1:-none}" \
      --preview='echo {} \
        | cut -d: -f1 \
        | xargs git stash show --color=always' \
      --preview-window='right:95%:hidden' \
      --bind='ctrl-v:toggle-preview' \
      | cut -d: -f1

  }

  case $1 in
    '-a'|'--apply' )
      local -r stash=$(filter 'apply')
      [[ -z ${stash} ]] && return 1
      git stash apply ${stash}
    ;;
    '-p'|'--print' )
      local -r stash=$(filter 'show')
      [[ -z ${stash} ]] && return 1
      git stash show -p ${stash}
    ;;
    '-d'|'--drop' )
      local -r stash=$(filter 'drop')
      [[ -z ${stash} ]] && return 1
      confirm git stash drop ${stash}
    ;;
    '-s'|'--save' )
      [[ $# > 1 ]] || return 1
      git stash save -u $2
    ;;
    * )
      git stash list
    ;;
  esac
}

function gu() {
  is_managed_by_git || return 1
  local -r url=$(git config --get remote.origin.url)
  if [[ ${OSTYPE} =~ 'darwin' ]]; then
    open ${url}
  elif [[ -n ${WSL_INTEROP} ]]; then
    '/mnt/c/Program Files/Google/Chrome/Application/chrome.exe' ${url}
  else
    xdg-open ${url}
  fi
}

function gph() {
  is_managed_by_git || return 1
  git push origin $(git branch | grep '^*' | cut -d' ' -f2)
}

function gclean() {
  is_managed_by_git || return 1
  git fetch --prune
  git switch develop &> /dev/null \
    && git branch --merged \
    | grep -v 'develop\|master\|main' \
    | xargs -I {} git branch -d {}
}

function __git_branch_list__() {
  is_managed_by_git || return 1
  git branch | grep -v "^*" | tr -d " " | fzf
}

function __git_working_tree_status__() {
  is_managed_by_git || return 1
  git status --porcelain | grep -e '^??' -e '^.M' -e '^.D' \
    | cut -c 4- \
    | sed "s@^@$(git rev-parse --show-toplevel)/@" \
    | xargs -I{} realpath --relative-to=. {} \
    | fzf --preview='git diff --color=always {}' \
      --preview-window='right:95%:hidden' \
      --bind='ctrl-v:toggle-preview'
}

function print_updated_prs() {
  is_managed_by_git || return 1
  [[ -z ${commands[gh]} ]] \
    && { echo 'github cli is required'; return 1; }
  [[ -z ${commands[jq]} ]] \
    && { echo 'jq is required'; return 1; }

  function fetch_recent_prs() {
    gh pr list --assignee $(git config --global user.name) \
      --state all \
      --limit 5 \
      | awk '{print $1, $2}'
  }

  function fetch_pr_updated_at() {
    gh api "https://api.github.com/repos/${1}/pulls/${2}" \
      | jq '.updated_at' \
      | grep -o '[0-9]*-[0-9]*-[0-9]*'
  }

  local -r repo=$(git config --get remote.origin.url | sed 's/\.git$//' | rev | cut -d/ -f 1,2 | rev)
  fetch_recent_prs | while read -r pr; do
    local number=$(echo ${pr} | cut -d' ' -f1)
    local name=$(echo ${pr} | cut -d' ' -f2)
    [[ $(date '+%Y-%m-%d') =~ $(fetch_pr_updated_at ${repo} ${number}) ]] || continue
    echo ${name}
    echo "https://github.com/${repo}/pull/${number}"
  done
}


function gmr() {
  is_managed_by_git || return 1
  [[ -z ${commands[jq]} ]] && { echo 'jq is required'; return 1; }

  local -r url=$(curl --header "PRIVATE-TOKEN: ${GITLAB_ACCESS_TOKEN}" \
    "https://${GITLAB_FQDN}/api/v4/projects/$(git config --get remote.origin.url | cut -d/ -f 4- | sed 's@/@%2F@g;s/.git$//')/merge_requests?source_branch=$(git branch --show-current)" | jq -r '.[0].web_url')

  if [[ ${OSTYPE} =~ 'darwin' ]]; then
    open ${url}
  elif [[ -n ${WSL_INTEROP} ]]; then
    '/mnt/c/Program Files/Google/Chrome/Application/chrome.exe' ${url}
  else
    xdg-open ${url}
  fi
}

function git_clone_to_path() {
  local repo_path=$(sed 's/[^:]*:\/\/[^\/]*\/\([^\.]*\)\.git/\1/' <<< $1 | xargs dirname)
  mkdir -p ${PWD}/${repo_path}
  (
    cd ${PWD}/${repo_path}
    [[ -d $(echo $1 | xargs basename | cut -d. -f1) ]] || git clone $1
  )
}

function gitlab_projects_total_pages_by_group_id() {
  [[ $# -eq 0 ]] && return 1

  local -r total=$(curl -i -s --header "PRIVATE-TOKEN: ${GITLAB_ACCESS_TOKEN}" \
    "https://${GITLAB_FQDN}/api/v4/groups/$1/projects?include_subgroups=true&simple=true&per_page=1" \
    | grep X-Total: | cut -d' ' -f2 | sed 's/[[:space:]]//')
  expr ${total} / 100 + 1
}

function recursive_git_clone_to_path_by_group_id() {
  [[ -z ${commands[jq]} ]] \
    && { echo 'jq is required'; return 1; }
  [[ $# -eq 0 ]] && return 1

  for i in $(seq $(gitlab_projects_total_pages_by_group_id $1)); do
    for repo in $(curl -s --header "PRIVATE-TOKEN: ${GITLAB_ACCESS_TOKEN}" \
      "https://${GITLAB_FQDN}/api/v4/groups/$1/projects?include_subgroups=true&simple=true&per_page=100&page=$i" \
      | jq -r '.[].http_url_to_repo'); do
      git_clone_to_path $repo
    done
  done
}

alias gs='git status'
alias ga='git add'
alias gcm='git commit -m'
alias gl='git log --pretty=oneline -n 30 --graph --abbrev-commit --stat'
alias gb='git branch'
alias gsw='git switch'
alias grs='git restore'
alias gpl='git pull origin'
alias gd='git diff --histogram'
alias gdc='git diff --histogram --cached'
alias gc1='git clone -b master --depth 1'
alias gcp='git cherry-pick'
alias gc='git_clone_to_path'
alias rgc='recursive_git_clone_to_path_by_group_id'

alias -g @gb='$(__git_branch_list__)'
alias -g @gw='$(__git_working_tree_status__)'
