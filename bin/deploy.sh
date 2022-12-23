#!/usr/bin/env bash

set -euCo pipefail

function create_symlink() {
  local -r repo_name=$(basename $(git config --get remote.origin.url) | sed 's/.git//')
  local -r root=$(dirname $(realpath $0) | sed "s/\(${repo_name}\).*/\1/")

  ls -A ${root}/home | while read -r file; do
    ln -s "${root}/home/${file}" "${HOME}/"
  done

  ls -A ${root}/config | while read -r dir; do
    ln -s "${root}/config/${dir}" "${HOME}/.config/"
  done
}

function main() {
  create_symlink
}

main $@
