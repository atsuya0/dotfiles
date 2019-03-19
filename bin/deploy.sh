#!/usr/bin/env bash

set -euCo pipefail

function main() {
  local -r home="${DOTFILES}/home"

  ls -A ${home} | while read -r file; do
    local filepath="${home}/${file}"

    [[ -f ${filepath} ]] && ln -s ${filepath} ${HOME}/
    [[ -d ${filepath} && ${file} == '.config' ]] && ln -s ${filepath}/* ${XDG_CONFIG_HOME:-${HOME}/.config}/
    [[ -d ${filepath} && ${file} == '.cache' ]] && ln -s ${filepath}/* ${XDG_CACHE_HOME:-${HOME}/.cache}/
  done
}

main $@
