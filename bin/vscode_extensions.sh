#!/usr/bin/env bash

set -euCo pipefail

function main() {
  which code &> /dev/null || return 1

  local -r store="${DOTFIELS:-${HOME}/dotfiles}/doc/extensions.txt"
  local -r error_msg='extension is not saved\nplease execute: save'

  case $1 in
    'save' )
      local -r extensions=$(code --list-extensions)
      [[ -e ${store} ]] \
        && diff -s ${store} <(echo ${extensions[@]}) > /dev/null \
        && return
      echo ${extensions} > ${store}
    ;;
    'install' )
      [[ -e ${store} ]] || { echo ${error_msg}; return 1; }
      cat ${store} | while read -r extension; do
        code --install-extension ${extension}
      done
    ;;
    * )
      [[ -e ${store} ]] || { echo ${error_msg}; return 1; }
      cat ${store}
    ;;
  esac
}

main $@
