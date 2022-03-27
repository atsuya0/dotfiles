autoload -Uz add-zsh-hook
source "${ZDOTDIR}/zshrc.d/env.zsh"
source "${ZDOTDIR}/zshrc.d/init.zsh"

# A list of non-alphanumeric characters considered part of a word by the line editor.
WORDCHARS='*?_-[]~&;!#$%^(){}<>' # /\=|.,
# REPORTTIME=5
# start/stop characters (usually assigned to ^S/^Q) is disabled
unsetopt flow_control
# Disabled beep
unsetopt beep
unsetopt list_beep
unsetopt hist_beep
# Try to correct the spelling of commands.
setopt nocorrect
# Do not exit on end-of-file (assigned to ^D).  Require the use of exit or logout instead.
setopt ignore_eof
# Allows `>' redirection to truncate existing files.  Otherwise `>!' or `>|' must be used to truncate a file.
unsetopt clobber
# Causes field splitting to be performed on unquoted parameter expansions.
# setopt sh_word_split

setopt notify
setopt print_eight_bit
# setopt bsd_echo

() {
  if [[ -n ${WSL_INTEROP} ]]; then
    local -r zsh='/usr/share'
  elif [[ ${OSTYPE} == 'linux-gnu' ]]; then
    local -r zsh='/usr/share/zsh/plugins'
  elif [[ ${OSTYPE} =~ 'darwin' ]]; then
    local -r zsh='/usr/local/share'
  fi
  source "${zsh}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" 2> /dev/null
  # source "${zsh}/zsh-autosuggestions/zsh-autosuggestions.zsh" 2> /dev/null
}

function ignore_absolute_paths() {
  local -ar paths=(
    "${HOME}/Pictures"
    "${HOME}/Library"
    "${HOME}/.cache/dein/repos"
    "${HOME}/.cache/dein/.cache"
    "${HOME}/.cache/pip"
    "${HOME}/.cache/jedi"
    "${HOME}/.cache/go-build"
    "${HOME}/.cache/fontconfig"
    "${HOME}/.cache/neosnippet"
    "${HOME}/.cache/mesa_shader_cache"
    "${HOME}/.cache/chromium"
    "${HOME}/.config/chromium"
    "${HOME}/.config/Code\\\ -\\\ OSS"
    "${HOME}/.vscode-oss"
    "${HOME}/.config/nvim/undo"
    "${HOME}/.local/lib"
    "${HOME}/.rustup"
    "${HOME}/.cargo"
    "${HOME}/.gem"
    "${HOME}/.vscode/extensions"
    "${HOME}/.npm/_cacache"
    "${HOME}/.java"
    "${HOME}/workspace/docker"
    "${HOME}/workspace/develop"
    "${HOME}/.Trash"
    "${GOPATH}/pkg"
    "${GOPATH}/src"
    "${DOTFILES}/config/cache/dein/repos"
    "${DOTFILES}/config/cache/dein/.cache"
  )
  local IFS=$'\n'

  echo "${paths[*]}" \
    | grep "^$(pwd)" \
    | sed "s@$(pwd)@.@;s/.*/-path & -prune -o/g"
}

function ignore_dirs() {
  local -ar ignore_dirs=(
    '.git'
    'node_modules' # node.js
    'target' # rust
    'bundle' # rails
    'tmp/cache' # rails
    '.terraform'
  )
  print -C 1 ${ignore_dirs[@]} \
    | sed 's/.*/-path \\*&\\* -prune -o/'
}

function ignore_filetypes() {
  local -ar ignore_filetypes=(
    'pdf' 'png' 'jpg' 'jpeg' 'mp3' 'mp4' 'tar.gz' 'zip'
  )
  print -C 1 ${ignore_filetypes[@]} \
    | sed 's/.*/-name \\*& -prune -o/'
}

autoload -Uz colors && colors
source "${ZDOTDIR}/zshrc.d/prompt.zsh"
# source "${ZDOTDIR}/zshrc.d/tmux_status.zsh"
source "${ZDOTDIR}/zshrc.d/completion.zsh"
source "${ZDOTDIR}/zshrc.d/history.zsh"
source "${ZDOTDIR}/zshrc.d/keybind.zsh"
source "${ZDOTDIR}/zshrc.d/fzf.zsh"
source "${ZDOTDIR}/zshrc.d/functions.zsh"
source "${ZDOTDIR}/zshrc.d/aliases.zsh"
() {
  local -r zsh="${ZDOTDIR}/zshrc.d/private.zsh"
  [[ -e ${zsh} ]] && source ${zsh}
}

source <(scd script)
source <(cremem script)
alias c='cremem'
