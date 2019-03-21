#!/usr/bin/env bash

set -euCo pipefail

function main() {
  local -r home="${DOTFILES}/home"

  ls -A ${home} | while read -r file; do
    local filepath="${home}/${file}"

    [[ -d ${filepath} && ${file} == '.config' ]] \
      && ln -sf ${filepath}/* "${XDG_CONFIG_HOME:-${HOME}/.config}/"
    [[ -d ${filepath} && ${file} == '.cache' ]] \
      && ln -sf ${filepath}/* "${XDG_CACHE_HOME:-${HOME}/.cache}/"
    ln -sf ${filepath} ${HOME}/
  done
}

main $@
