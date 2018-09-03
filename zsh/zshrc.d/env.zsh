typeset -gr path=(
  "${GOPATH}/bin"
  "$(ruby -e 'print Gem.user_dir')/bin"
  /usr/bin
  /usr/bin/core_perl
)

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

export NVM_DIR="${HOME}/.nvm" # Node.jsのversion管理

export TRASH_PATH="${HOME}/.Trash"
export SECOND_LIST_PATH="${HOME}/.second_list"
# export LOG_PATH="${GOPATH}/go_log"
