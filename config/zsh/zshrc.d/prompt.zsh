function __prompt__() { # カレントディレクトリのpathを画面の横幅に応じて短縮する。
  local -r wd=$(pwd | sed "s@${HOME}@~@")

  local short_wd
  () {
    # 表示するディレクトリ名の文字数を決める
    local path_chars_num=$(($(($(tput cols) / 3)) / $(echo ${wd} | grep -o '[~/]' | wc -l)))
    [[ 0 -ge ${path_chars_num} ]] && path_chars_num=1
    short_wd=$(echo ${wd} | shorten_path ${path_chars_num})
  }

  local graphic_prompt
  () {
    local -r icon=''
    local -r blue="%{${fg[blue]}${bg[black]}%}"
    local -r blue_bg="%{${fg[black]}${bg[blue]}%}"
    local -r green="%{${fg[green]}${bg[black]}%}"

    [[ ${KEYMAP} == 'vicmd' ]] \
      && local mode="${green} NORM ${blue_bg}" \
      || local mode="${blue} INS ${blue_bg}"

    graphic_prompt="${mode}${icon}${blue_bg} ${short_wd} ${blue}${icon} %{${reset_color}%}"
  }

  if [[ ${OSTYPE} == 'linux-gnu' && -n ${WINDOWID} && $(ps hco cmd ${PPID}) != 'nvim' ]] \
    || [[ ${OSTYPE} == 'linux-gnu' && -n ${WSL_INTEROP} && $(ps hco cmd ${PPID}) != 'nvim' ]] \
    || [[ ${OSTYPE} =~ 'darwin' && $(ps co comm ${PPID} | tail -1) != 'nvim' ]]; then
    PROMPT=${graphic_prompt}
  else
    PROMPT="%n %{${fg[blue]}%}${short_wd} %{${reset_color}%}$ "
  fi

  zle reset-prompt
}
# add-zsh-hook precmd __prompt__
zle -N zle-line-init __prompt__
zle -N zle-keymap-select __prompt__

function __git_prompt__() {
  RPROMPT=''
  [[ -z ${commands[git]} ]] && return 1
  git status &> /dev/null || return 1
  local -ar git_info=("${(f)$(git status --porcelain --branch)}")
  local -r icon=''
  local branch="${icon} $(sed 's/## \([^\.]*\).*/\1/' <<< ${git_info[1]})"

  if [[ $(echo ${git_info[1]} | grep -o '\[.*\]') =~ '[ahead .*]' ]]; then
    branch="%{${fg_bold[blue]}%}${branch}%{${reset_color}%}"
  elif [[ $(echo ${git_info[1]} | grep -o '\[.*\]') =~ '[behind .*]' ]]; then
    branch="%{${fg_bold[red]}%}${branch}%{${reset_color}%}"
  else
    branch="%{${fg_bold[green]}%}${branch}%{${reset_color}%}"
  fi

  local file uncommited=0 unadded=0 untracked=0
  for file in ${git_info[2,-1]}; do
    if [[ $(cut -c1-2 <<< ${file}) == '??' ]]; then
      (( untracked++ ))
    elif [[ $(cut -c1-2 <<< ${file}) =~ '( |M|A|R|U)(M|D|U)' ]]; then
      (( unadded++ ))
    elif [[ $(cut -c1-2 <<< ${file}) =~ '(M|A|R|D) ' ]]; then
      (( uncommited++ ))
    fi
  done

  function format_status() {
    [[ 0 -ne ${1} ]] \
      && echo "%{${fg[${2}]}%}${3}${1}%{${reset_color}%} "
  }

  RPROMPT="${branch} $(format_status ${uncommited} 'yellow' '!')$(format_status ${unadded} 'red' '+')$(format_status ${untracked} 'green' '?')"
}
add-zsh-hook precmd __git_prompt__

# コマンド実行後にRPROMPTを非表示
setopt transient_rprompt
