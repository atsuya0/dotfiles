#!/usr/bin/bash

function download_libraries() {
  for library in $@; do
    go get -u ${library}
  done
}

function install_my_tool() {
  local root="github.com/$(git config --global user.name)"
  [[ -d ${GOPATH}/src/${root}/$1 ]] && return 1

  git clone https://${root}/$1.git ${GOPATH}/src/${root}/$1 || return 1
  cd ${GOPATH}/src/${root}/$1
  [[ -f 'Gopkg.toml' ]] && dep ensure
  go install
  cd $(dirname $(readlink -f $0))
}

function main() {
  type go &> /dev/null || return 1
  [[ -z ${GOPATH} ]] && return 1

  declare -a libraries=(
    'github.com/nsf/gocode'
    'golang.org/x/tools/cmd/goimports'
    'github.com/golang/dep/cmd/dep'
    'github.com/spf13/cobra/cobra'
  )

  mkdir -p ${GOPATH}/{src,bin,pkg}
  download_libraries ${libraries}

  declare -a tools=(
    'go-choice'
    'second'
    'trash'
    'crawl-img'
  )

  type dep &> /dev/null || return 1
  type git &> /dev/null || return 1
  for tool in ${tools}; do
    install_my_tool ${tool}
  done
}

main
trap "cd $(dirname $(readlink -f $0))" EXIT
