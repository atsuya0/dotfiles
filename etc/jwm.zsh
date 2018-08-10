function jwm() { # dockerでjwmを動かす。ブラウザのデータを復号・暗号
  is_docker_running || return

  local passwd && printf '\rpassword:' && read -s passwd
  [[ -e /tmp/.X11-unix/X1 ]] && local exists='true' || Xephyr -wr -resizeable :1 > /dev/null 2>&1 &

  local workdir="${HOME}/workspace/docker/ubuntu-jwm"
  local chrome="${workdir}/google-chrome"

  # 復号
  [[ -e "${chrome}.tar.enc" ]] && type openssl > /dev/null 2>&1 \
    && openssl enc -d -aes-256-cbc -salt -k ${passwd} -in "${chrome}.tar.enc" -out "${chrome}.tar" \
    && command rm "${chrome}.tar.enc" || return 1
  # 展開
  [[ -e "${chrome}.tar" ]] && tar -xf "${chrome}.tar" -C ${workdir} && command rm "${chrome}.tar"

  docker run $@ \
    -v ${workdir}/data:/home/docker/data \
    -v ${chrome}:/home/docker/.config/google-chrome \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v /run/user/${UID}/pulse/native:/tmp/pulse/native \
    -v ${HOME}/.config/pulse/cookie:/tmp/pulse/cookie \
    -it --rm ${USER}/ubuntu-jwm > /dev/null 2>&1

  [[ -z ${exists} ]] && pkill Xephyr > /dev/null 2>&1
  # 書庫化
  [[ -e ${chrome} ]] && tar -cf "${chrome}.tar" -C ${workdir} $(basename ${chrome}) && command rm -r ${chrome}
  # 暗号
  [[ -e "${chrome}.tar" ]] && type openssl > /dev/null 2>&1 \
    && openssl enc -e -aes-256-cbc -salt -k ${passwd} -in "${chrome}.tar" -out "${chrome}.tar.enc" \
    && command rm "${chrome}.tar"
}
