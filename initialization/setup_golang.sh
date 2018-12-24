#!/usr/bin/env bash

set -euCo pipefail

function install_my_tool() {
  local root
  root="github.com/$(git config --global user.name)"
  [[ -d ${GOPATH}/src/${root}/$1 ]] && return 1

  git clone "https://${root}/$1.git" "${GOPATH}/src/${root}/$1" || return 1
  cd "${GOPATH}/src/${root}/$1"
  [[ -f 'Gopkg.toml' ]] && dep ensure
  go install
  cd "$(dirname $(realpath $0))"
}

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

main
trap "cd $(dirname $(realpath $0))" EXIT
