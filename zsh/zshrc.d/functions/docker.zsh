function is_docker_running() { # docker daemonが起動しているか
  docker info &> /dev/null && return 0
  echo 'Is the docker daemon running?'
  print -z 'sudo systemctl start docker'

  return 1
}

function dc() {
  is_docker_running && docker-compose $@
}

function jwm() { # dockerでjwmを動かす。
  is_docker_running || return 1

  [[ -e /tmp/.X11-unix/X1 ]] \
    && local exists='true' \
    || Xephyr -wr -resizeable :1 &> /dev/null &

  local share="${HOME}/workspace/docker/jwm/share" docker='/home/docker'
  [[ -d ${share} ]] || return 1

  docker run $@ \
    -v "${share}/data:${docker}/data" \
    -v "${share}/epiphany:${docker}/.config/epiphany" \
    -v "${share}/google-chrome:${docker}/.config/google-chrome" \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v "/run/user/${UID}/pulse/native:/tmp/pulse/native" \
    -v "${HOME}/.config/pulse/cookie:/tmp/pulse/cookie" \
    -it --rm "${USER}/jwm" &> /dev/null

  [[ -z ${exists} ]] && pkill Xephyr &> /dev/null
}

function drm() { # dockerのコンテナを選択して破棄
  is_docker_running && type fzf &> /dev/null && typeset -r container=$(docker ps -a | sed 1d | fzf --header="$(docker ps -a | sed -n 1p)")
  [[ -n ${container} ]] && echo "${container}" | tr -s ' ' | cut -d' ' -f1 | xargs docker rm
}

function drmi() { # dockerのimageを選択して破棄
  is_docker_running && type fzf &> /dev/null && typeset -r image=$(docker images | sed 1d | fzf --header="$(docker images | sed -n 1p)")
  [[ -n ${image} ]] && echo "${image}" | tr -s ' ' | cut -d' ' -f3 | xargs docker rmi
}
