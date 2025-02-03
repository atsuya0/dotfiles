source "${ZDOTDIR}/zshrc.d/zim.zsh"

export STARSHIP_CONFIG=${DOTFILES}/config/starship/starship.toml
eval "$(starship init zsh)"

() { # OSC 133
  local -r weztermsh="${ZDOTDIR}/zshrc.d/wezterm.sh"
  [[ ! -f ${weztermsh} ]] \
    && curl --silent -L https://raw.githubusercontent.com/wez/wezterm/refs/heads/main/assets/shell-integration/wezterm.sh -o ${weztermsh}
  source ${weztermsh}
}

source "${ZDOTDIR}/zshrc.d/env.zsh"
source "${ZDOTDIR}/zshrc.d/init.zsh"
source "${ZDOTDIR}/zshrc.d/history.zsh"
source "${ZDOTDIR}/zshrc.d/keybind.zsh"
source "${ZDOTDIR}/zshrc.d/functions.zsh"
source "${ZDOTDIR}/zshrc.d/aliases.zsh"

source <(wezterm shell-completion --shell zsh)
