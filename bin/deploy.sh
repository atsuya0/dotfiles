#!/usr/bin/env bash

set -euCo pipefail

function link_config_file() {
  local -r dotfiles="${DOTFILES:-${HOME}/dotfiles}"

  ls -A "${dotfiles}/home" | while read -r file; do
    [[ -f "${HOME}/${file}" ]] && rm -r "${HOME}/${file}"
    ln -s "${dotfiles}/home/${file}" ${HOME}/
  done

  ls "${dotfiles}/config" | while read -r file; do
    local target="${XDG_CONFIG_HOME:-${HOME}/.config}/${file}"
    [[ -f ${target} ]] && rm -r ${target}
    ln -s "${dotfiles}/config/${file}" ${target}
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
  # fetch_surround-nvim
}

main $@
