function _path_prompt() { # カレントディレクトリのpathを画面の横幅に応じて短縮する。
  typeset -r pwd=$(pwd | sed "s@${HOME}@~@")
  local num
  # 表示するディレクトリ名の文字数を決める
  let num=$(expr $(tput cols) - 55 | xargs -I{} sh -c 'test 1 -gt {} && echo 1 || echo {}')/$(echo ${pwd} | grep -o '[~/]' | wc -l)
  [[ 0 -eq ${num} ]] && num=1

  # CUI/neovim と GUI で表示を変える
  [[ -z ${WINDOWID} || $(ps -ho args ${PPID} | tr -s ' ' | cut -d' ' -f1) == 'nvim' ]] \
    && PROMPT="%n@%m ${fg[blue]}$(echo ${pwd} | sed "s@\(/[^/]\{${num}\}\)[^/]*@\1@g")${reset_color} " \
    || PROMPT="%{${fg[blue]}${bg[black]}%}%n%{${fg[magenta]}${bg[black]}%}@%{${fg[blue]}${bg[black]}%}%m %{${fg[black]}${bg[blue]}%}%{${fg[black]}${bg[blue]}%} $(echo ${pwd} | sed "s@\(/[^/]\{${num}\}\)[^/]*@\1@g") %{${reset_color}${fg[blue]}%} "
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _path_prompt

function _git_prompt() {
  RPROMPT=''
  type git > /dev/null 2>&1 || return 1
  git status > /dev/null 2>&1 || return 1
  local git_info=("${(f)$(git status --porcelain --branch)}")

  local branch="[$(echo ${git_info[1]} | sed 's/## \([^\.]*\).*/\1/')]"
  if [[ $(echo ${git_info[1]} | grep -o '\[.*\]') =~ '[ahead .*]' ]]; then
    branch="%{${fg[blue]}%}${branch}"
  elif [[ $(echo ${git_info[1]} | grep -o '\[.*\]') =~ '[behind .*]' ]]; then
    branch="%{${fg[red]}%}${branch}"
  else
    branch="%{${fg[green]}%}${branch}"
  fi

  local file uncommited=0 unadded=0 untracked=0
  for file in ${git_info[2,-1]}; do
    if [[ $(echo ${file} | cut -c1-2) == '??' ]]; then
      (( untracked++ ))
    elif [[ $(echo ${file} | cut -c1-2) =~ '( |M|A|R|U)(M|D|U)' ]]; then
      (( unadded++ ))
    elif [[ $(echo ${file} | cut -c1-2) =~ '(M|A|R|D) ' ]]; then
      (( uncommited++ ))
    fi
  done
  local git_status
  [[ 0 -ne ${uncommited} ]] && git_status="%{${fg[yellow]}%}!${uncommited} "
  [[ 0 -ne ${unadded} ]] && git_status="${git_status}%{${fg[red]}%}+${unadded} "
  [[ 0 -ne ${untracked} ]] && git_status="${git_status}%{${fg[green]}%}?${untracked} "
  RPROMPT="${git_status}${branch}"
}
add-zsh-hook precmd _git_prompt

# コマンド実行後にRPROMPTを非表示
setopt transient_rprompt
