# .zshenv is loaded for the first time in zsh config files.
# .zshenv is the only zsh config file to load before execute shellscript.

if [[ -n ${WSL_INTEROP} ]]; then
  export PATH='/usr/local/bin:/usr/bin:/usr/sbin'
elif [[ ${OSTYPE} == 'linux-gnu' ]]; then
  export PATH='/usr/bin:/usr/bin/core_perl'
elif [[ ${OSTYPE} =~ 'darwin' ]]; then
  export PATH='/usr/local/bin:/usr/bin:/bin:/usr/sbin/:/sbin:/opt/homebrew/bin'
fi
export LANG='ja_JP.UTF-8'
export TERM='xterm-256color'
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_CACHE_HOME="${HOME}/.cache"
export XDG_DATA_HOME="${HOME}/.local/share"
export MANPAGER='less'
export EDITOR='nvim'
export VISUAL='nvim'
export SUDO_EDITOR='nvim --noplugin' # sudoedit file_name
export GREP_COLOR='1;33'
export LESS='-iMRgW -j10 -x2 --no-init --quit-if-one-screen +5'
export LESS_TERMCAP_mb="$(echo -n '\e[34;1m')"
export LESS_TERMCAP_md="$(echo -n '\e[34;1m')"
export LESS_TERMCAP_me="$(echo -n '\e[37m')"
export LESS_TERMCAP_se="$(echo -n '\e[37m')"
export LESS_TERMCAP_so="$(echo -n '\e[31;40;1m')"
export LESS_TERMCAP_ue="$(echo -n '\e[32;1m')"
export LESS_TERMCAP_us="$(echo -n '\e[32;1m')"

export GOPATH="${HOME}/workspace/go"

export DOTFILES="${HOME}/dotfiles"
