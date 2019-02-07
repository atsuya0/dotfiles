#!/usr/bin/env bash

set -euCo pipefail

function install_my_tool() {
  local root
  root="github.com/$(git config --global user.name)"
  [[ -d ${GOPATH}/src/${root}/$1 ]] && return 1

  git clone "https://${root}/$1.git" "${GOPATH}/src/${root}/$1" || return 1
  cd "${GOPATH}/src/${root}/$1"
  [[ -f 'Gopkg.toml' ]] && dep ensure -vendor-only
  go install
  cd "$(dirname $(realpath $0))"
}

function main() {
  which dep &> /dev/null || return 1
  which git &> /dev/null || return 1

  local -ar tools=(
    'go-choice'
    'second'
    'trash'
    'crawl-img'
  )

  local tool
  for tool in ${tools}; do
    install_my_tool ${tool}
  done
}

trap "cd $(dirname $(realpath $0))" EXIT
main
