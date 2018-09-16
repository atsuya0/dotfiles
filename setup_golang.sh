#!/usr/bin/bash

function download_libraries() {
  go get -u github.com/nsf/gocode
  go get -u golang.org/x/tools/cmd/goimports
  go get -u github.com/golang/dep/cmd/dep
  go get -u github.com/spf13/cobra/cobra
}

function install_my_tool() {
  git clone https://github.com/tayusa/$1.git ${GOPATH}/src/github.com/tayusa/$1 \
    && dep ensure \
    && go install github.com/tayusa/$1
}

function main() {
  type go &> /dev/null || return 1
  [[ -z ${GOPATH} ]] && return 1

  mkdir -p ${GOPATH}/{src,bin,pkg}
  download_libraries
  type dep &> /dev/null || return 1
  install_my_tool go-choice
  install_my_tool trash
  install_my_tool second
}

main || return 1
return 0
