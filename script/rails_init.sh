#!/usr/bin/env bash

function get_conf_path() {
  readlink -f ${0%.*}
}

function create_Gemfile() {
  docker run --rm -v "$(pwd):/app" -w "/app" ruby:latest bundle init || return 1
  sed -i 's/# \(gem "rails"\)/\1/' Gemfile || return 1
  touch Gemfile.lock
}

function rails_new() {
  cp "$(get_conf_path)/Dockerfile" ./
  docker build -t $USER/rails . || return 1
  docker run --rm -it -v "$(pwd):/$1" $USER/rails rails new "/$1" -B || return 1
}

function create_dc_yaml() {
  cp "$(get_conf_path)/docker-compose.yml" ./
  sed -i "s/{{1}}/$1/;s/{{2}}/$(id -u)/g" ./docker-compose.yml
}

function main() {
  [[ $# -eq 0 ]] && return

  local app=$1

  [[ -d ${app} ]] || mkdir ${app}
  [[ $(dirname $(pwd)) == ${app} ]] || cd ${app}

  create_Gemfile || return
  rails_new ${app} || return

  echo "sudo chown -R $(whoami):$(whoami) ."
  sudo chown -R $(whoami):$(whoami) .

  echo '/config/master.key' > ./.dockerignore
  create_dc_yaml ${app} || return
}

main $@
