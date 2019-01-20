alias la='ls -A --color=auto'
alias ll='ls -FAlhtr --color=auto --time-style="+%Y/%m/%d %H:%M:%S"'
alias grep='grep --color=auto'
alias mv='mv -iv'
alias cp='cp -iv'
alias ln='ln -iv'
alias rm=':'
alias mkdir='mkdir -pv'
alias hist='history -i 1'
alias free='free -wh'
alias du='du -h'
alias df='df -Th'
alias mk='make'
alias pgrep='pgrep --list-full'
alias diff='diff --color'
alias ip='ip --color=auto'
alias nano='nano -$ -l -i -O -m -c' # '-$liOmc' does not work.

alias tree='tree -C'
alias xbg="xbacklight -get | xargs printf '%.0f%%\n'"
alias xephyr='Xephyr -wr -resizeable :1' # white
alias open='xdg-open'
alias c='chromium'
alias noise='paplay /usr/share/sounds/alsa/Noise.wav'
alias poweroff='interactive systemctl poweroff'
alias reboot='interactive systemctl reboot'
alias logout='interactive i3-msg exit'
alias lock='light-locker-command -l'
alias wallpaper='feh --no-fehbg --bg-scale /home/tayusa/contents/pictures/wallpaper/arch/Ju5PuBC.jpg'

alias -g @g='| grep'
alias -g @l='| less'
alias -g @j='| jq'
alias -g lf='$(ls | fzf)'
alias -g ff='$(find -type f | fzf)'
alias -g ..2='../..'
alias -g ..3='../../..'

alias -s txt='less'
alias -s {html,md,pdf,mp3,mp4}='chromium'
alias -s {png,jpg,jpeg}='feh'

# docker error creating new backup file
alias no_metacopy='echo N | sudo tee /sys/module/overlay/parameters/metacopy'
