#!/usr/bin/env bash

set -euCo pipefail

function main() {
  [[ $# -eq 0 ]] && return 1

  local -r app=$1
  local -r rails="$1/rails"

  [[ -d ${rails} ]] || mkdir -p ${rails}

  (
    [[ $(dirname $(pwd)) == ${app} ]] || cd ${app}

    cp "$(realpath ${0%.*})/docker-compose.yml" ./
    sed -i "s/{{1}}/${app}/g" ./docker-compose.yml

    cp "$(realpath ${0%.*})/Makefile" ./
  )

  (
    [[ $(dirname $(pwd)) == ${rails} ]] || cd ${rails}
    docker run --rm -it \
      -v "$(pwd):/${app}" -w "/${app}" $USER/rails \
      bundle exec rails new . -d mysql
    docker run --rm -it \
      -v "$(pwd):/${app}" -w "/${app}" $USER/rails \
      bundle install --path vendor/bundle --jobs=4
    cp "$(realpath ${0%.*})/Dockerfile" ./
    echo '/config/master.key' > ./.dockerignore
  )

  echo 'chown'
  sudo chown -R $(whoami) ${rails}
}

main $@
