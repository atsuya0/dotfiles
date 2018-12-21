function is_docker_running() {
  docker info &> /dev/null && return 0
  echo 'Is the docker daemon running?'
  print -z 'sudo systemctl start docker'

  return 1
}

function docker-compose() {
  cmd_exists 'docker-compose' || { echo 'Not installed'; return 1; }
  is_docker_running && command docker-compose $@
}
alias dc='docker-compose'

function jwm() { # dockerでjwmを動かす。
  is_docker_running || return 1

  [[ -e /tmp/.X11-unix/X1 ]] \
    && local -r existed=1 \
    || {
        local -r existed=0;
        Xephyr -wr -resizeable :1 &> /dev/null &;
       }

  function share() {
    [[ $1 != 's' ]] && return 1
    local -r \
      root="${HOME}/workspace/docker/ubuntu-jwm/share" \
      docker='/home/docker'
    [[ -d ${root} ]] || return 1

    echo "-v ${root}/data:${docker}/data" \
      && echo "-v ${root}/epiphany:${docker}/.config/epiphany" \
      && echo "-v ${root}/google-chrome:${docker}/.config/google-chrome"
  }

  docker run $(share $1) \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v "/run/user/${UID}/pulse/native:/tmp/pulse/native" \
    -v "${HOME}/.config/pulse/cookie:/tmp/pulse/cookie" \
    -it --rm "${USER}/ubuntu-jwm" &> /dev/null

  [[ ${existed} -eq 0 ]] && pkill Xephyr
}

function drm() { # dockerのコンテナを選択して破棄
  is_docker_running || return 1
  type fzf &> /dev/null || return 1

  local -r container=$(
    docker ps -a | sed 1d | fzf --header="$(docker ps -a | sed -n 1p)"
  )
  [[ -n ${container} ]] \
    && echo "${container}" | tr -s ' ' | cut -d' ' -f1 | xargs docker rm
}

function drmi() { # dockerのimageを選択して破棄
  is_docker_running || return 1
  type fzf &> /dev/null || return 1

  local -r image=$(
    docker images | sed 1d | fzf --header="$(docker images | sed -n 1p)"
  )
  [[ -n ${image} ]] \
    && echo "${image}" | tr -s ' ' | cut -d' ' -f3 | xargs docker rmi
}
