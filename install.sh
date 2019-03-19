#!/usr/bin/env bash

set -euCo pipefail

function fetch_dotfiles() {
  curl -fsSLO https://github.com/tayusa/dotfiles/archive/master.tar.gz
  tar -xzf master.tar.gz
  rm master.tar.gz
  mv dotfiles-master "${DOTFILES}"
}

function main() {
  export DOTFILES="${HOME}/dotfiles"
  fetch_dotfiles
}

main
