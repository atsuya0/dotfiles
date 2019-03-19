#!/usr/bin/env bash

set -euCo pipefail

function fetch_libraries() {
  local -ar libraries=(
    'github.com/mdempsky/gocode'
    'golang.org/x/tools/cmd/goimports'
    'github.com/jstemmer/gotags'
  )

  go get -u ${libraries}
}

function main() {
  which go &> /dev/null || return 1
  [[ -z ${GOPATH} ]] && return 1

  mkdir -p ${GOPATH}/{src,bin,pkg}

  fetch_libraries
}

main
