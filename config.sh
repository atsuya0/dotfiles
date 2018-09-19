#!/usr/bin/bash

function is_not_empty() {
  [[ -z $(find $1 -maxdepth 0 -type d -empty) ]] \
    && return 0 \
    || return 1
}

function place_config_files() {
  [[ $# -lt 2 ]] && return 1
  mkdir -p $2
  if [[ -f $1 && -s $1 ]]; then
    ln $1 $2/
  elif [[ -d $1 ]] && is_not_empty $1/; then
    ln $1/* $2/
  else
    return 1
  fi
  return 0
}

# zsh
function init_zsh() {
cat << "EOF" > ${HOME}/.zshenv
export DOTFILES=${HOME}/dotfiles
export ZDOTDIR=${DOTFILES}/zsh
source ${ZDOTDIR}/.zshenv
EOF
}

# neovim
function init_nvim() {
  local dot=${DOTFILES}/vim
  place_config_files "${dot}/init.vim" "${XDG_CONFIG_HOME}/nvim" \
    || return 1
  place_config_files "${dot}/dein" "${HOME}/.cache/dein/toml" \
    || return 1
}

# termite
function init_termite() {
  place_config_files "${DOTFILES}/termite/config" "${XDG_CONFIG_HOME}/termite" \
    || return 1
}

# i3
function init_i3() {
  local dot=${DOTFILES}/i3
  place_config_files "${dot}/config" "${XDG_CONFIG_HOME}/i3" \
    || return 1
  place_config_files "${dot}/i3blocks" "${XDG_CONFIG_HOME}/i3blocks" \
    || return 1
}

# x11
function init_x11() {
  place_config_files "${DOTFILES}/x11/local" ${HOME} \
    || return 1
}

# rofi
function init_rofi() {
  place_config_files "${DOTFILES}/rofi" "${XDG_CONFIG_HOME}/rofi" \
    || return 1
}

function main() {
  [[ $(id -u) -eq 0 ]] && return 1
  [[ -z ${DOTFILES} ]] && export DOTFILES=${HOME}/dotfiles
  [[ -z ${XDG_CONFIG_HOME} ]] && export XDG_CONFIG_HOME=${HOME}/.config

  init_zsh
  init_nvim || echo 'Place failed: nvim'
  init_termite || echo 'Place failed: termite'
  init_i3 || echo 'Place failed: i3'
  init_x11 || echo 'Place failed: x11'
  init_rofi || echo 'Place failed: rofi'
}

main
