alias la='ls -A --color=auto'
alias ll='ls -FAlht --color=auto'
alias grep='grep --color=auto'
# alias mv='mv -i' alias cp='cp -i'
alias ln='ln -i'
alias rm='echo "zsh: command not found: rm"'
alias mkdir='mkdir -vp'
alias free='free -wh'
alias du='du -h'
alias df='df -hT'
alias ip='ip -c'
alias pgrep='pgrep -a'
alias nano='nano -$ -l -i -O -m -c' # オブションは個々に指定してないと効かない

alias tree='tree -C'
alias xbg="xbacklight -get | xargs printf '%.0f%%\n'"
alias xephyr='Xephyr -wr -resizeable :1' # x serverのネスト。白背景。window可変。
alias open='xdg-open'
alias crm='chromium'
alias noise='paplay /usr/share/sounds/alsa/Noise.wav'
alias poweroff='interactive systemctl poweroff'
alias reboot='interactive systemctl reboot'
alias logout='interactive i3-msg exit'

alias -g @g='| grep'
alias -g @l='| less'
alias -g @j='| jq'
alias -g ..2='../..'
alias -g ..3='../../..'
alias -s txt=less
alias -s {html,md,pdf}=chromium
alias -s {png,jpg}=feh
alias -s {mp3}=paplay
alias -s py=python3
