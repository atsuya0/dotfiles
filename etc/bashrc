#
# ~/.bashrc
#
#対話的に呼び出されたなら終わる
[[ $- != *i* ]] && return

#プロンプト
PS1='\[\033[01;36m\]\u@\h\[\033[00m\] \[\033[01;34m\]\w\[\033[00m\] \$ '

#重複履歴を保存しない,空白から始めたコマンドを保存しない
HISTCONTROL=ignoreboth
#履歴サイズ
HISTSIZE=10000
HISTFILESIZE=10000
#履歴に追加しないコマンド
HISTIGNORE=history:exit:cd*:ls*:ll:rm*:pushd*:dirs:popd*:poweroff:reboot:lsblk:umount*:mkdir*:rmdir*:date:tree*:unzip*:touch*:ranger:feh*:export*:which*:startx:
#履歴に時刻を付ける
HISTTIMEFORMAT='%m/%d/%T | '

shopt -s checkwinsize
shopt -s autocd
shopt -s cdspell
shopt -s extglob
shopt -s globstar
set -o noclobber

bind C-F:menu-complete
bind C-B:menu-complete-backword

[[ -x /usr/bin/lesspipe ]] && eval "$(SHELL=/bin/sh lesspipe)"
#コマンド履歴を共有
function Share_History {
    history -a #キャッシュを~/.bash_historyに書き込む
    history -c #キャッシュを削除
    history -r #キャッシュに~/.bash_histroyを書き込む
}
#プロントを表示する度に実行するコマンド
PROMPT_COMMAND='Share_History'

function ls() {
  [[ -z $(command ls $@) ]] && command ls -FA --color=auto $@ || command ls -F --color=auto $@
}

function up() {
  local str
  if [[ $# -eq 0 ]] && type fzf > /dev/null 2>&1; then
    str=$(pwd | sed ':a;s@/[^/]*$@@;p;/^\/[^\/]*$/!ba;d' | \
      fzf --preview='tree -C {}' --preview-window='right:hidden' --bind='ctrl-v:toggle-preview')
  elif expr ${1-dummy} + 1 > /dev/null 2>&1; then
    str=$(seq -s: $1 | sed 's/://g;s@.@\.\./@g')
  elif [[ -d $1 ]]; then
    str=$1
  fi
  command cd ${str:-.}
}
function _up() {
  COMPREPLY=( $(compgen -W "$(pwd | sed ':a;s@/[^/]*$@@;p;/^\/[^\/]*$/!ba;d')" -- ${COMP_WORDS[COMP_CWORD]}) )
}
complete -F _up up

# alias
alias ll='command ls -FAlht --color=auto'
alias grep='grep -i --color=auto'
alias cd='pushd > /dev/null 2>&1'
alias mv='mv -i'
alias cp='cp -i'
alias ln='ln -i'
alias rm='rm -i'
alias mkdir='mkdir -vp'
alias free='free -wh'
alias du='du -h'
alias df='df -hT'
alias dirs='dirs -v'
alias ip='ip -c'
alias nano='nano -$ -l -i -O -m -c' # オブションは個々に指定する
alias tree='tree -C'
