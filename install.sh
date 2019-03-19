#!/usr/bin/env bash

set -euCo pipefail

function fetch_dotfiles() {
  curl -fsSLO https://github.com/tayusa/dotfiles/archive/master.zip
  bsdtar xf master.zip
  rm master.zip
  mv dotfiles-mater "${DOTFILES}"
}

function main() {
  export DOTFILES="${HOME}/dotfiles"
  fetch_dotfiles
}

main
