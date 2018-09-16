#!/usr/bin/bash

function is_not_empty() {
  [[ -z $(find $1 -maxdepth 0 -type d -empty) ]] \
    && return 0 \
    || return 1
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
  local src=${DOTFILES}/vim

  local nvim=${XDG_CONFIG_HOME}/nvim
  mkdir -p ${nvim}
  [[ -s ${src}/init.vim ]] \
    && ln ${src}/init.vim ${nvim}/

  local dein=${HOME}/.cache/dein/toml
  mkdir -p ${dein}
  is_not_empty ${src}/dein/ \
    && ln ${src}/dein/* ${dein}/
}

# termite
function init_termite() {
  local src=${DOTFILES}/termite termite=${XDG_CONFIG_HOME}/termite
  mkdir -p ${termite}
  [[ -s ${src}/config ]] \
    && ln ${src}/config ${termite}/
}

# i3
function init_i3() {
  local src=${DOTFILES}/i3
  mkdir -p ${XDG_CONFIG_HOME}/{i3,i3blocks}

  [[ -s ${src}/config ]] \
    && ln ${src}/config ${XDG_CONFIG_HOME}/i3/ \

  is_not_empty ${src}/i3blocks/ \
    && ln ${src}/i3blocks/* ${XDG_CONFIG_HOME}/i3blocks/
}

# x11
function init_x11() {
  local src=${DOTFILES}/x11/local
  is_not_empty ${src}/ \
    && ln ${src}/* ${HOME}/
}

# rofi
function init_rofi() {
  local src=${DOTFILES}/rofi rofi=${XDG_CONFIG_HOME}/rofi
  mkdir -p ${rofi}
  is_not_empty ${src}/ \
    && ln ${src}/* ${rofi}/
}

function main() {
  [[ -z ${DOTFILES} ]] && export DOTFILES=${HOME}/dotfiles
  [[ -z ${XDG_CONFIG_HOME} ]] && export XDG_CONFIG_HOME=${HOME}/.config
  init_zsh
  init_nvim
  init_termite
  init_i3
  init_x11
  init_rofi
}

main
