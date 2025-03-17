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

source "${ZDOTDIR}/zshrc.d/env.zsh"
source "${ZDOTDIR}/zshrc.d/history.zsh"
source "${ZDOTDIR}/zshrc.d/keybind.zsh"
source "${ZDOTDIR}/zshrc.d/functions.zsh"
source "${ZDOTDIR}/zshrc.d/aliases.zsh"

[[ -n ${commands[wezterm]} ]] && source <(wezterm shell-completion --shell zsh)
[[ -n ${commands[helm]} ]] && source <(helm completion zsh)
[[ -n ${commands[helmfile]} ]] && source <(helmfile completion zsh)
[[ -n ${commands[istioctl]} ]] && source <(istioctl completion zsh)
[[ -n ${commands[stern]} ]] && source <(stern --completion zsh)
autoload -U +X bashcompinit && bashcompinit
[[ -f "${XDG_DATA_HOME}/mise/installs/terraform/latest/bin/terraform" ]] \
  && complete -o nospace -C "${XDG_DATA_HOME}/mise/installs/terraform/latest/bin/terraform" terraform
[[ -f /opt/homebrew/bin/aws_completer ]] \
  && complete -C /opt/homebrew/bin/aws_completer aws

[[ ${WEZTERM_PANE} -eq 0 ]] && [[ -n ${commands[trs]} ]] && trs auto-remove
