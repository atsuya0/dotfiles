if [[ -n ${commands[eza]} ]]; then
  alias ls='eza'
  alias la='eza -A'
  alias ll="eza -Al --time-style='+%Y/%m/%d %H:%M:%S' -s date"
else
  alias ls='ls --color=auto'
  alias la='ls -A --color=auto'
  alias ll='ls -FAlhtr --color=auto --time-style="+%Y/%m/%d %H:%M:%S"'
fi
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
alias diff='diff --color'
alias nano='nano -$ -l -i -O -m -c' # '-$liOmc' does not work.

alias lg='lazygit'
alias k='kubectl'
alias rgon='rg --no-filename --no-line-number --no-heading'

alias iv='images_viewer.sh'

alias -g @g='| grep'
alias -g @l='| less'
alias -g @j='| jq'
alias -g L='$(ls | fzf)'
alias -g F='$(find -type f | fzf)'
alias -g ..2='../..'
alias -g ..3='../../..'

alias -s txt='less'
alias -s {png,jpg,jpeg}='chafa --clear -f sixel --align mid,mid'
