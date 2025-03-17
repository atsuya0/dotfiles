source "${ZDOTDIR}/zshrc.d/zim.zsh"

# A list of non-alphanumeric characters considered part of a word by the line editor.
WORDCHARS='*?_-[]~&;!#$%^(){}<>' # /\=|.,

export STARSHIP_CONFIG=${DOTFILES}/config/starship/starship.toml
eval "$(starship init zsh)"
() { # https://mise.jdx.dev
  [[ -z ${commands[mise]} ]] && return
  [[ -n ${commands[brew]} ]] \
    && eval "$($(brew --prefix mise)/bin/mise activate zsh)"
}
[[ -n ${commands[zoxide]} ]] && eval "$(zoxide init zsh)"
[[ -n ${commands[pyenv]} ]] && eval "$(pyenv init --path)"

() { # OSC 133
  [[ -z ${WEZTERM_UNIX_SOCKET} ]] && return
  local -r weztermsh="${ZDOTDIR}/zshrc.d/wezterm.sh"
  [[ ! -f ${weztermsh} ]] \
    && curl --silent -L https://raw.githubusercontent.com/wez/wezterm/refs/heads/main/assets/shell-integration/wezterm.sh -o ${weztermsh}
  source ${weztermsh}
}

source <(wezterm shell-completion --shell zsh)
[[ -n ${commands[mise]} ]] && source <(mise completion zsh)

source "${ZDOTDIR}/zshrc.d/env.zsh"
source "${ZDOTDIR}/zshrc.d/history.zsh"
source "${ZDOTDIR}/zshrc.d/keybind.zsh"
source "${ZDOTDIR}/zshrc.d/functions.zsh"
source "${ZDOTDIR}/zshrc.d/aliases.zsh"

[[ ${WEZTERM_PANE} -eq 0 ]] && [[ -n ${commands[trs]} ]] && trs auto-remove
