#!/usr/bin/env bash

set -euCo pipefail

function link_config_file() {
  local -r config="${DOTFILES:-${HOME}/dotfiles}/config"

  ls -A "${config}/home" | while read -r file; do
    ln -sf "${config}/home/${file}" ${HOME}/
  done

  ls "${config}/config" | while read -r file; do
    rm -r "${XDG_CONFIG_HOME:-${HOME}/.config}/${file}"
    ln -sf "${config}/config/${file}" "${XDG_CONFIG_HOME:-${HOME}/.config}/"
  done

  ls "${config}/cache" | while read -r file; do
    rm -r "${XDG_CACHE_HOME:-${HOME}/.cache}/${file}"
    ln -sf "${config}/cache/${file}" "${XDG_CACHE_HOME:-${HOME}/.cache}/"
  done
}

function fetch_surround-nvim() {
  local -r nvim_dir="${HOME}/workspace/develop/neovim"
  mkdir -p ${nvim_dir}
  (
    cd ${nvim_dir}
    git clone https://github.com/tayusa/surround.nvim
  )
}

function main() {
  link_config_file
  fetch_surround-nvim
}

main $@
