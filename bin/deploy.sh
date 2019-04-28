#!/usr/bin/env bash

set -euCo pipefail

function main() {
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

main $@
