export TF_LOG=trace
export TF_LOG_PATH="${HOME}/.terraform.log"
export PYENV_ROOT="${HOME}/.pyenv"
export NNN_PLUG='p:preview-tui;z:!trs move "$nnn"*'
export NNN_OPENER="${DOTFILES}/bin/nnn_opener.sh"
export FZF_DEFAULT_OPTS="-m --height=80% --reverse --exit-0 --bind 'ctrl-y:execute-silent(echo {} | cut -f2- | pbcopy)+abort'" # <C-y>で文字列をコピー
export FZF_CTRL_R_OPTS="--preview='echo {}' --preview-window=down:3:hidden:wrap --bind 'ctrl-v:toggle-preview'" # <C-v>で見切れたコマンドを表示

export TRASH_CAN_PATH="${HOME}/Trash"

typeset -a path=()
[[ -f '/opt/homebrew/bin/brew' ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
echo $GO_PATH
typeset -ar path=(
  $([[ -d ${DOTFILES}/bin ]] && echo ${DOTFILES}/bin)
  $([[ -d ${GOPATH}/bin ]] && echo ${GOPATH}/bin)
  $([[ -d ${PYENV_ROOT}/bin ]] && echo ${PYENV_ROOT}/bin)
  $([[ -d "${HOME}/.krew/bin" ]] && echo "${HOME}/.krew/bin")
  ${path}
  "${HOMEBREW_PREFIX:=/usr/local}/opt/coreutils/libexec/gnubin"
  "${HOMEBREW_PREFIX:=/usr/local}/opt/findutils/libexec/gnubin"
  "${HOMEBREW_PREFIX:=/usr/local}/opt/gnu-sed/libexec/gnubin"
  /usr/local/bin
  /usr/bin
  /bin
  /usr/sbin
  /sbin
)

[[ -n ${commands[limactl]} && $(limactl list -q 2> /dev/null | head -1) == 'default' ]] \
  && export DOCKER_HOST=$(limactl list default --format 'unix://{{.Dir}}/sock/docker.sock')
