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

alias rgc='recursive_git_clone_to_path_by_group_id'

alias -g @gw='$(__git_working_tree_status__)'
