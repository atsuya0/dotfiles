# The shell is interactive.
[[ $- != *i* ]] && return
#----------------------------------------
# environment variables
#----------------------------------------
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_CACHE_HOME="${HOME}/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export GREP_COLOR='1;33'
export LESS='-iMRgW -j10 -x2 --no-init --quit-if-one-screen +5'
# export LESS_TERMCAP_mb="$(echo -n '\e[34;1m')"
# export LESS_TERMCAP_md="$(echo -n '\e[34;1m')"
# export LESS_TERMCAP_me="$(echo -n '\e[37m')"
# export LESS_TERMCAP_se="$(echo -n '\e[37m')"
# export LESS_TERMCAP_so="$(echo -n '\e[31;40;1m')"
# export LESS_TERMCAP_ue="$(echo -n '\e[32;1m')"
# export LESS_TERMCAP_us="$(echo -n '\e[32;1m')"
export MANPAGER='less'
export EDITOR='nano'
export VISUAL='nano'
export SUDO_EDITOR='rnano'
#----------------------------------------
# shell variables
#----------------------------------------
# prompt
PS1='\[\033[01;36m\]\u\[\033[00m\] \[\033[01;34m\]\w\[\033[00m\] \$ '
# lines which begin with a space character are not saved. (ignorespace)
# lines matching the previous history entry to not be saved. (ignoredups)
HISTCONTROL=ignoreboth
# history size
HISTSIZE=10000
HISTFILESIZE=10000
# history ignore
HISTIGNORE=:cd*:ls*:ll*:rm*:dirs:pushd*:popd*:poweroff:reboot:mount*:umount*:mkdir*:rmdir*:date*:tree*:touch*:export*:which*:feh*:
# history time format
HISTTIMEFORMAT='%m/%d/%T | '
#----------------------------------------
# shell options(shopt [-s(set),-u(unset)])
#----------------------------------------
shopt -s autocd
shopt -s cdable_vars
shopt -s cdspell
shopt -s checkjobs
shopt -s checkwinsize
shopt -s direxpand
shopt -u dotglob
shopt -u execfail
shopt -s extglob
shopt -s globstar # **
shopt -u nocaseglob
shopt -u nocasematch
shopt -s nullglob
#----------------------------------------
# etc
#----------------------------------------
set -o noclobber
[[ -x /usr/bin/lesspipe ]] && eval "$(SHELL=/bin/sh lesspipe)"
function share_history() {
  # -a : append history lines from this session to the history file
  # -c : clear the history list by deleting all of the entries
  # -r : read the history file and append the contents to the history list
  history -a && history -c && history -r
}
# The value is executed as a command prior to issuing each primary prompt.
PROMPT_COMMAND='share_history'
#----------------------------------------
# key bindings
#----------------------------------------
bind -m emacs TAB:menu-complete
bind -m emacs C-f:menu-complete
bind -m emacs C-b:menu-complete-backward
bind -m vi-insert C-l:clear-screen
bind -m vi-insert C-f:forward-char
bind -m vi-insert C-b:backward-char
bind -m vi-insert C-a:beginning-of-line
bind -m vi-insert C-e:end-of-line
bind -m vi-insert M-f:forward-word
bind -m vi-insert M-b:backward-word
bind -m vi-insert C-d:delete-char
#----------------------------------------
# fucntions
#----------------------------------------
function print_parents() {
  pwd | sed '/[^\/]$/s@$@/@;:a;s@[^/]\+/$@@;p;/^\/$/!ba;d'
}

function up() {
  if [[ $# -eq 0 ]] \
    && which fzf &> /dev/null && type print_parents &> /dev/null
  then
    local -r parent_path=$(print_parents \
      | fzf --delimiter='/' --nth='-2' --bind='ctrl-v:toggle-preview' \
          --preview='tree -C {}' --preview-window='right' || return 0)
  elif [[ $1 =~ ^[0-9]+$ ]]; then
    local -r parent_path=$(seq -s '' $1 | sed 's@.@\.\./@g')
  else
    local -r parent_path=$1
  fi

  builtin cd ${parent_path:-.}
}
function _up() {
  COMPREPLY=( $(compgen -W "$(print_parents)" -- ${COMP_WORDS[COMP_CWORD]}) )
}
complete -F _up up

function trash_function() {
  function mv_files_to_trash_can() {
    local -r dest="${trash_can}/$(date +%F)"
    [[ -d ${dest} ]] || mkdir ${dest}

    # mv -bv --suffix=_$(date +%T) $@ -t ${dest}
    local file
    for file in $@; do
      mv -iv ${file} \
        "${dest}/$(sed "s/\(^[^.]*\)\.\(.*\)/\1_$(date +%T).\2/" <<< ${file})"
    done
  }

  function rm_files_in_trash_can() {
    [[ $(pwd) =~ ${trash_can} ]] \
      && : | xargs -p rm -r $@ \
      || { echo 'It can not be executed in that directory'; return 1; }
  }

  local -r trash_can="${HOME}/trash_can"
  [[ -d ${trash_can} ]] || mkdir ${trash_can}

  case $1 in
    'mv' )
      [[ $# -eq 1 ]] && { echo 'missing file operand'; return 1; }
      shift
      mv_files_to_trash_can $@
    ;;
    'rm' )
      [[ $# -eq 1 ]] && { echo 'missing file operand'; return 1; }
      shift
      rm_files_in_trash_can $@
    ;;
    'size' )
      du -hs ${trash_can} | awk '{print $1}'
    ;;
  esac
}
alias tmv='trash_function mv'
alias trm='trash_function rm'
alias tsz='trash_function size'
#----------------------------------------
# aliases
#----------------------------------------
alias rm="echo Don\'t use the rm command"
alias ls='ls --color=auto'
alias la='ls -A --color=auto'
alias ll='ls -FAlhtr --color=auto --time-style="+%Y/%m/%d %H:%M:%S"'
alias grep='grep --color=auto'
alias mv='mv -iv'
alias cp='cp -iv'
alias ln='ln -iv'
alias mkdir='mkdir -pv'
alias free='free -wh'
alias du='du -h'
alias df='df -Th'
alias pgrep='pgrep --list-full'
alias diff='diff --color'
alias mk='make'
alias nano='nano -$ -l -i -O -m -c' # '-$liOmc' does not work.
alias cd='pushd &> /dev/null'
alias dirs='dirs -v'
alias ip='ip --color=auto'
