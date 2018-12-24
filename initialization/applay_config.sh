#!/usr/bin/env bash

set -euCo pipefail

function is_not_empty() {
  [[ -z $(find $1 -maxdepth 0 -type d -empty) ]] \
    && return 0 \
    || return 1
}

# $1 is souce which is file or directory. $2 is destination.
function place_config_files() {
  [[ $# -lt 2 ]] && return 1
  mkdir -p $2

  if [[ -f $1 && -s $1 ]]; then
    ln $1 "$2/"
  elif [[ -d $1 ]] && is_not_empty "$1/"; then
    ln $1/* "$2/"
  else
    return 1
  fi
  return 0
}

# shell
function init_zsh() {
  cat << "EOF" > ${HOME}/.zshenv
export DOTFILES=${HOME}/dotfiles
export ZDOTDIR=${DOTFILES}/zsh
source ${ZDOTDIR}/.zshenv
EOF
}

# editor
function init_nvim() {
  local -r dot="${DOTFILES}/vim"
  place_config_files "${dot}/init.vim" "${XDG_CONFIG_HOME}/nvim" \
    || return 1
  place_config_files "${dot}/dein" "${HOME}/.cache/dein/toml" \
    || return 1
}

# terminal
function init_termite() {
  place_config_files "${DOTFILES}/terminal/termite/config" "${XDG_CONFIG_HOME}/termite" \
    || return 1
}

# terminal
function init_alacritty() {
  place_config_files "${DOTFILES}/terminal/alacritty/alacritty.yml" "${XDG_CONFIG_HOME}/alacritty" \
    || return 1
}

# window manager
function init_i3() {
  place_config_files "${DOTFILES}/i3" "${XDG_CONFIG_HOME}/i3" \
    || return 1
}

# status line
function init_i3blocks() {
  place_config_files "${DOTFILES}/i3blocks" "${XDG_CONFIG_HOME}/i3blocks" \
    || return 1
}

# x window system
function init_x11() {
  place_config_files "${DOTFILES}/x11" ${HOME} \
    || return 1
  for file in $(ls "${DOTFILES}/x11"); do
    mv "${HOME}/${file}" "${HOME}/.${file}"
  done
}

# launcher
function init_rofi() {
  place_config_files "${DOTFILES}/rofi" "${XDG_CONFIG_HOME}/rofi" \
    || return 1
}

# notification-deamon
function init_dunst() {
  place_config_files "${DOTFILES}/etc/dunstrc" "${XDG_CONFIG_HOME}" \
    || return 1
}

# file manager
function init_ranger() {
  which ranger &> /dev/null || return 1
  ranger --copy-config=all \
    && sed -i 's/.*preview_images[[:space:]].*/set preview_images true/' \
      "${XDG_CONFIG_HOME}/ranger/rc.conf"
}

function main() {
  [[ $(id -u) -eq 0 ]] && return 1 # The current user is the root user.
  [[ -z ${DOTFILES} ]] && export DOTFILES="${HOME}/dotfiles"
  [[ -z ${XDG_CONFIG_HOME} ]] && export XDG_CONFIG_HOME="${HOME}/.config"

  init_zsh
  init_nvim || echo 'Place failed: nvim'
  init_termite || echo 'Place failed: termite'
  init_i3 || echo 'Place failed: i3'
  init_i3blocks || echo 'Place failed: i3blocks'
  init_x11 || echo 'Place failed: x11'
  init_rofi || echo 'Place failed: rofi'
  init_dunst || echo 'Place failed: dunst'
  init_ranger || echo 'Cannot create ranger config file'
}

main
