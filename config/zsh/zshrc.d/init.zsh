[[ -e ${_CD_HISTORY} ]] || export _CD_HISTORY=$(mktemp)

[[ ${WEZTERM_PANE} -eq 0 ]] && [[ -n ${commands[trs]} ]] && trs auto-remove

# A list of non-alphanumeric characters considered part of a word by the line editor.
WORDCHARS='*?_-[]~&;!#$%^(){}<>' # /\=|.,

() { # https://mise.jdx.dev
  [[ -z ${commands[mise]} ]] && return
  [[ -n ${commands[brew]} ]] \
    && eval "$($(brew --prefix mise)/bin/mise activate zsh)"
}
[[ -n ${commands[pyenv]} ]] && eval "$(pyenv init --path)"
[[ -n ${commands[scd]} ]] && source <(scd script)
