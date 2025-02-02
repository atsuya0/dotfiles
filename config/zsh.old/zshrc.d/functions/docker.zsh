function is_docker_running() {
  docker info &> /dev/null && return 0
  echo 'Is the docker daemon running?'
  [[ ${OSTYPE} == 'linux-gnu' ]] \
    && print -z 'sudo systemctl start docker'

  return 1
}

function image_exists() {
  [[ $# -eq 0 ]] && return 1
  is_docker_running || return 1

  docker images --format "{{.Repository}}" | grep -q "^${1}$" \
    && return 0 \
    || return 1
}

function _image_exists() {
  docker info &> /dev/null || return 1

  _values \
    $(docker images --format "{{.Repository}}")
}
compdef _image_exists image_exists

# function docker-compose() {
#   [[ -z ${commands[docker-compose]} ]] && { echo 'Not installed'; return 1; }
#   type is_docker_running &> /dev/null \
#     && is_docker_running \
#     && command docker-compose $@
# }

function drm() { # dockerのcontainerを選択して破棄
  is_docker_running || return 1
  [[ -z ${commands[fzf]} ]] && return 1

  local -r container=$(
    docker ps -a | sed 1d | fzf --header="$(docker ps -a | sed -n 1p)"
  )
  [[ -n ${container} ]] \
    && echo "${container}" | tr -s ' ' | cut -d' ' -f1 | xargs docker rm
}

function drmi() { # dockerのimageを選択して破棄
  is_docker_running || return 1
  [[ -z ${commands[fzf]} ]] && return 1

  local -r image=$(
    docker images | sed 1d | fzf --header="$(docker images | sed -n 1p)"
  )
  [[ -n ${image} ]] \
    && echo "${image}" | tr -s ' ' | cut -d' ' -f3 | xargs docker rmi
}

function jwm() { # dockerでjwmを動かす。
  is_docker_running || return 1

  [[ -e /tmp/.X11-unix/X1 ]] \
    || Xephyr -wr -resizeable :1 &> /dev/null &

  docker run \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v "/run/user/${UID}/pulse/native:/tmp/pulse/native" \
    -v "${HOME}/.config/pulse/cookie:/tmp/pulse/cookie" \
    -it --rm "${USER}/ubuntu-jwm" &> /dev/null

  pkill Xephyr &> /dev/null
}

function to_pdf() {
  [[ $# -eq 0 ]] && return 1
  is_docker_running || return 1

  local -r image="${USER}/imagemagick-alpine"
  image_exists ${image} || return 1

  local dir
  for dir in $@; do
    docker run --rm -it -v ${PWD}:/images -w /images ${image} \
      convert "${dir}/*" "${dir}.pdf"
  done
}

function convert() {
  [[ $# -eq 0 ]] && return 1
  is_docker_running || return 1

  local -r image="${USER}/imagemagick-alpine"
  image_exists ${image} || return 1

  docker run --rm -it -v ${PWD}:/images -w /images ${image} \
    convert $@
}
