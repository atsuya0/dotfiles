if [[ ${OSTYPE} == 'linux-gnu' ]]; then
  alias pgrep='pgrep --list-full'
  alias poweroff='confirm systemctl poweroff'
  alias reboot='confirm systemctl reboot'
  alias xbg="xbacklight -get | xargs printf '%.0f%%\n'"
  alias xephyr='Xephyr -wr -resizeable :1'
  # alias lock='light-locker-command -l'
  alias lock='i3lock'
  alias noise='paplay /usr/share/sounds/alsa/Noise.wav'
  alias wallpaper="feh --no-fehbg --bg-scale ${HOME}/contents/pictures/wallpaper/arch/Ju5PuBC.jpg"
  alias usb_tethering='sudo systemctl start dhcpcd@enp0s20f0u3'
  alias sound='sound.sh $(echo "up\ndown\nmute" | fzf)'
  alias light='xbacklight -$(echo "inc\ndec" | fzf) 10'
elif [[ ${OSTYPE} =~ 'darwin' ]]; then
  alias format='diskutil eraseDisk FAT32 MBRFormat'
  alias rotate="displayplacer list | tail -1 | sed 's/degree:90\"$/degree:0\"/;ta;s/degree:0\"$/degree:90\"/;:a;s/res:\([0-9]*\)x\([0-9]*\)/res:\2x\1/2' | cut -d' ' -f 2- | xargs displayplacer"
fi

alias ls='ls --color=auto'
alias la='ls -A --color=auto'
alias ll='ls -FAlhtr --color=auto --time-style="+%Y/%m/%d %H:%M:%S"'
alias grep='grep --color=auto'
alias mv='mv -i'
alias cp='cp -i'
alias ln='ln -iv'
alias rm=':'
alias mkdir='mkdir -pv'
alias hist='history -i 1'
alias free='free -wh'
alias du='du -h'
alias df='df -Th'
alias mk='make'
alias diff='diff --color'
alias ip='ip --color=auto'
alias nano='nano -$ -l -i -O -m -c' # '-$liOmc' does not work.

alias rgon='rg --no-filename --no-line-number --no-heading'
alias tree='tree -C'
alias dc='docker-compose'
alias k='kubectl'
alias n3='nnn -caP p'
alias pip-upgrade="pip list -o | sed '1,2d' | tr -s ' ' | cut -d' ' -f1 | xargs -I{} pip install -U {}"
alias pip3-upgrade="pip3 list -o | sed '1,2d' | tr -s ' ' | cut -d' ' -f1 | xargs -I{} pip3 install -U {}"

alias -g @g='| grep'
alias -g @l='| less'
alias -g @j='| jq'
alias -g L='$(ls | fzf)'
alias -g F='$(find -type f | fzf)'
alias -g ..2='../..'
alias -g ..3='../../..'

alias -s txt='less'
#alias -s {html,md,pdf,mp3,mp4}='google-chrome-stable'
alias -s {png,jpg,jpeg}='kitty +kitten icat'
