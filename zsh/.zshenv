# .zshenv is loaded for the first time in zsh config files.
# .zshenv is the only zsh config file to load before execute shellscript.

export PATH='/usr/bin:/usr/bin/core_perl'
export LANG='ja_JP.UTF-8'
export TERM='xterm-256color'
export XDG_CONFIG_HOME="${HOME}/.config"

export GREP_COLOR='1;33' # grep
export LESS='-iMRgW -j10 -x2 --no-init --quit-if-one-screen +5' # less
export LESS_TERMCAP_mb="$(echo -n '\e[34;1m')"
export LESS_TERMCAP_md="$(echo -n '\e[34;1m')"
export LESS_TERMCAP_me="$(echo -n '\e[37m')"
export LESS_TERMCAP_se="$(echo -n '\e[37m')"
export LESS_TERMCAP_so="$(echo -n '\e[31;40;1m')"
export LESS_TERMCAP_ue="$(echo -n '\e[32;1m')"
export LESS_TERMCAP_us="$(echo -n '\e[32;1m')"

export MANPAGER='less' # man
export EDITOR='nvim' # lessでvを押すなどに使う
export SUDO_EDITOR='nvim -Zu NORC' # sudoedit file_name

export GOPATH="${HOME}/workspace/go"

# .zshrcの先頭でtmuxを起動するため、このファイルに記述している。
export DOTFILES="${HOME}/dotfiles"
