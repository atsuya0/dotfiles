function is_docker_running() { # docker daemonが起動しているか
  docker info > /dev/null 2>&1 && return 0
  echo 'Is the docker daemon running?'
  print -z 'sudo systemctl start docker'

  return 1
}

function dc() {
  is_docker_running && docker-compose $@
}

function jwm() { # dockerでjwmを動かす。
  is_docker_running || return

  [[ -e /tmp/.X11-unix/X1 ]] && local exists='true' || Xephyr -wr -resizeable :1 > /dev/null 2>&1 &

  local workdir="${HOME}/workspace/docker/ubuntu-jwm"

  docker run $@ \
    -v ${workdir}/data:/home/docker/data \
    -v ${workdir}/epiphany:/home/docker/.config/epiphany \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v /run/user/${UID}/pulse/native:/tmp/pulse/native \
    -v ${HOME}/.config/pulse/cookie:/tmp/pulse/cookie \
    -it --rm ${USER}/ubuntu-jwm > /dev/null 2>&1

  [[ -z ${exists} ]] && pkill Xephyr > /dev/null 2>&1
}

function drm() { # dockerのコンテナを選択して破棄
  is_docker_running && type fzf > /dev/null 2>&1 && typeset -r container=$(docker ps -a | sed 1d | fzf --header="$(docker ps -a | sed -n 1p)")
  [[ -n ${container} ]] && echo ${container} | tr -s ' ' | cut -d' ' -f1 | xargs docker rm
}

function drmi() { # dockerのimageを選択して破棄
  is_docker_running && type fzf > /dev/null 2>&1 && typeset -r image=$(docker images | sed 1d | fzf --header="$(docker images | sed -n 1p)")
  [[ -n ${image} ]] && echo ${image} | tr -s ' ' | cut -d' ' -f3 | xargs docker rmi
}
