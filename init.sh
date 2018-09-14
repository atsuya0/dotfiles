#!/usr/bin/bash

function is_not_empty() {
  [[ -z $(find $1 -maxdepth 0 -type d -empty) ]] \
    && return 1
    || return 0
}

# zsh
function init_zsh() {
cat << "EOF" > ${HOME}/.zshenv
export ZDOTDIR="${DOTFILES}/zsh"
source ${ZDOTDIR}/.zshenv
EOF
}

# neovim
function init_nvim() {
  local src="${DOTFILES}/vim"

  local nvim="${XDG_CONFIG_HOME}/nvim"
  mkdir "${nvim}"
  [[ -s "${src}/init.vim" ]] \
    && ln "${src}/init.vim" "${nvim}/"

  local dein="${HOME}/.cache/dein/toml"
  mkdir -p "${dein}"
  is_not_empty "${src}/dein/" \
    && ln "${src}/dein/*" "${dein}/"
}

# mlterm
function init_mlterm() {
  local src="${DOTFILES}/mlterm" mlterm="${HOME}/.mlterm"
  mkdir ${mlterm}
  is_not_empty "${src}/" \
    && ln "${src}/*" "${mlterm}/"
}

# i3
function init_i3() {
  local src="${DOTFILES}/i3"
  mkdir "${XDG_CONFIG_HOME}/{i3,i3blocks}"

  [[ -s "${src}/config" ]] \
    && ln "${src}/config" "${XDG_CONFIG_HOME}/i3" \

  is_not_empty "${src}/i3blocks/" \
    && ln "${src}/i3blocks/*" "${XDG_CONFIG_HOME}/i3blocks/"
}

# x11
function init_x11() {
  local src="${DOTFILES}/x11/local"
  is_not_empty "${src}/" \
    && ln "${src}/*" "${HOME}/"
}

# rofi
function init_rofi() {
  local src="${DOTFILES}/rofi" rofi="${XDG_CONFIG_HOME}/rofi"
  mkdir "${rofi}"
  is_not_empty "${src}/" \
    && ln "${src}/*" "${rofi}/"
}

function main() {
  init_zsh
  init_nvim
  init_mlterm
  init_i3
  init_x11
  init_rofi
}

main
