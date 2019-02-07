#!/usr/bin/env bash

set -euCo pipefail

function main() {
  which go &> /dev/null || return 1
  [[ -z ${GOPATH} ]] && return 1

  mkdir -p ${GOPATH}/{src,bin,pkg}

  local -ar libraries=(
    'github.com/nsf/gocode'
    'golang.org/x/tools/cmd/goimports'
    'github.com/jstemmer/gotags'
    'github.com/golang/dep/cmd/dep'
  )
  go get -u ${libraries}
}

main
