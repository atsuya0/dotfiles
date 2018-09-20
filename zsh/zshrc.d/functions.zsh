[[ -f "${ZDOTDIR}/zshrc.d/functions/cd.zsh" ]] \
  && source "${ZDOTDIR}/zshrc.d/functions/cd.zsh"
[[ -f "${ZDOTDIR}/zshrc.d/functions/docker.zsh" ]] \
  && source "${ZDOTDIR}/zshrc.d/functions/docker.zsh"
[[ -f "${ZDOTDIR}/zshrc.d/functions/git.zsh" ]] \
  && source "${ZDOTDIR}/zshrc.d/functions/git.zsh"
[[ -f "${ZDOTDIR}/zshrc.d/functions/wrapper.zsh" ]] \
  && source "${ZDOTDIR}/zshrc.d/functions/wrapper.zsh"
[[ -f "${ZDOTDIR}/zshrc.d/functions/second.zsh" ]] \
  && source "${ZDOTDIR}/zshrc.d/functions/second.zsh"
[[ -f "${ZDOTDIR}/zshrc.d/functions/trash.zsh" ]] \
  && source "${ZDOTDIR}/zshrc.d/functions/trash.zsh"

function vol() {
  # vol up    -> 音量を5%上げる
  # vol down  -> 音量を5%下げる
  # vol mute  -> muteの切り替え
  # vol       -> 音量を表示

  function get_index() {
    [[ $(pactl list sinks | grep 'RUNNING') != '' ]] \
      && pactl list sinks | grep -B 1 'RUNNING' | grep -o '[0-9]' \
      || pactl list sinks | head -1 | grep -o '[0-9]'
  }

  if [[ $1 == 'up' ]]; then
    pactl set-sink-volume "$(get_index)" +5%
  elif [[ $1 == 'down' ]]; then
    pactl set-sink-volume "$(get_index)" -5%
  elif [[ $1 == 'mute' ]]; then
    pactl set-sink-mute "$(get_index)" toggle
  else
    local run
    [[ $(pactl list sinks | grep 'RUNNING') != '' ]] && run="grep -A 10 'RUNNING'" || run='tee'
    pactl list sinks | eval "${run}" | grep -o '[0-9]*%' | head -1
  fi
}

function wifi() {
  if [[ $1 == '-r' ]]; then # 再始動
    netctl list | sed '/^\*/!d;s/[\* ]*//' | xargs sudo netctl restart
  elif [[ $1 == '-s' ]]; then
    netctl list | sed '/^\*/!d;s/[\* ]*//' | xargs sudo netctl stop
  elif type fzf &> /dev/null; then
    netctl list | fzf --select-1 | xargs sudo netctl start
  fi
}

function colors(){
  for fore in {30..37}; do
    echo "\e[${fore}m \\\e[${fore}m \e[m"
    for mode in 1 4 5; do
      echo -n "\e[${fore};${mode}m \\\e[${fore};${mode}m \e[m"
      for back in {40..47}; do
        echo -n "\e[${fore};${back};${mode}m \\\e[${fore};${back};${mode}m \e[m"
      done
      echo
    done
    echo
  done
}

function cmd_exists(){ # 関数やaliasに囚われないtype,which。 vim()で使う。
  [[ -n $(echo ${PATH//:/\\n} | xargs -I{} find {} -type f -name $1) ]] && return 0 || return 1
}

function dtr() { # 電源を入れてからのネットワークのデータ転送量を表示。
  cat /proc/net/dev | awk \
    '{if(match($0, /wlp4s0/)!=0) print "Wifi        : Receive",$2/(1024*1024),"MB","|","Transmit",$10/(1024*1024),"MB"} \
    {if(match($0, /bnep0/)!=0) print "Bluetooth Tethering : Receive",$2/(1024*1024),"MB","|","Transmit",$10/(1024*1024),"MB"}'
}

function interactive() { # 引数に指定したコマンドを実行するのに確認をとる。
  local input
  while [[ ${input} != 'yes' && ${input} != 'no' ]]; do
    printf '\ryes / no'
    read -s input
  done

  [[ ${input} == 'yes' ]] && command $@
}

function os() { # OSとKernelの情報を表示 (hostnamectl statusで表示できた)
  echo -n 'OS\t'
  uname -o | tr -d '\n'
  cat /etc/os-release | sed '/^PRETTY_NAME/!d;s/.*"\(.*\)".*/(\1)/'
  uname -sr | sed 's/\(.*\) \(.*\)/Kernel\t\1(\2)/'
}

function bat() { # 電池残量
  typeset -r bat='/sys/class/power_supply/BAT1'
  [[ -e ${bat} ]] && cat "${bat}/capacity" | sed 's/$/%/' || echo 'No Battery'
}

function bak() { # ファイルのバックアップをとる
  local file

  if [[ $1 == '-r' ]]; then # .bakを取り除く
    for file in $argv[2,-1]; do
      mv -i "${file}"  "${file%.bak}"
    done
  else # ファイル名の末尾に.bakをつけた複製を作成する
    for file in $@; do
      eval cp -ir "${file}{,.bak}"
    done
  fi
}

function init_test() {
  [[ -e ./test.sh ]] && return 1
  echo '#!/usr/bin/bash\n' > ./test.sh
  chmod +x ./test.sh
}

# bluetoothテザリング。
# anacondaのdbus-sendを使わないようにする。AC_CF_85_B7_9D_9Aはスマホのmacアドレス。
function bt() {
  typeset -r ADDR='AC:CF:85:B7:9D:9A'

  [[ $(systemctl is-active bluetooth) == 'inactive' ]] && sudo systemctl start bluetooth.service
  () {
    echo 'power on' \
      && sleep 1 \
      && echo "connect $1" \
      && sleep 3 \
      && echo 'quit'
  } ${ADDR} | bluetoothctl
  /usr/bin/dbus-send --system --type=method_call --dest=org.bluez /org/bluez/hci0/dev_${ADDR//:/_} org.bluez.Network1.Connect string:'nap'
  sudo dhcpcd bnep0
}

function fin() { # コマンドが終了したことを知らせる(ex: command ; fin)
  type i3-nagbar &> /dev/null && i3-nagbar -t warning -m 'finish' -f 'pango:IPAGothic Regular 10' &> /dev/null
}

function crypt() {
  # crypt test.txt
  # ファイルの暗号と復号を行う。暗号か復号はファイルの状態で自動で決める。

  ! type openssl &> /dev/null && echo 'require openssl' && return 1

  if [[ $(file $1 | cut -d' ' -f2-) == "openssl enc'd data with salted password" ]]; then
    local password
    while [[ -z ${password} ]]; do
      printf '\rpassword:'
      read password
    done
    openssl enc -d -aes-256-cbc -salt -k "${password}" -in $1 -out "${1%.enc}"
    command rm $1
  else
    local password_1
    while [[ -z ${password_1} ]]; do
      printf '\rpassword:'
      read password_1
    done
    local password_2
    while [[ -z ${password_2} ]]; do
      printf '\rretype password:'
      read password_2
    done
    [[ ${password_1} != ${password_2} ]] && tput dl1 && echo '\rfailed' && return 1
    openssl enc -e -aes-256-cbc -salt -k "${password_1}" -in $1 -out "$1.enc"
    command rm $1
  fi
  # tput dl1
}
function _crypt() {
  _files
}
compdef _crypt crypt

function md() { # マルチディスプレイ
  type xrandr &> /dev/null || return 1
  if [[ $1 == 'school' ]]; then
    xrandr --output HDMI1 --left-of eDP1 --mode 1600x900
  elif [[ $1 == 'home' ]]; then
    xrandr --output HDMI1 --left-of eDP1 --mode 1366x768
  elif [[ $1 == 'off' ]]; then
    xrandr --output "$(xrandr | grep ' connected' | grep -v 'primary' | cut -d' ' -f1)" --off
  elif [[ $1 == 'select' ]]; then
    type fzf &> /dev/null || return 1
    xrandr --output ${2:-VGA1} --left-of eDP1 --mode "$(xrandr | sed -n '/.* connected [^p].*/,/^[^ ]/p' | sed '1d;$d;s/  */ /g' | cut -d' ' -f2 | fzf)"
  fi
}
function _md() {
  _values \
    'args' \
    'school' \
    'home' \
    'off' \
    'select' \
}
compdef _md md

function rs() { # ファイル名から空白を除去
  for file in $@; do
    [[ -e ${file} && ${file} =~ ' ' ]] && mv "${file}" "$(echo ${file} | sed 's/ //g')"
  done
}

function rn() { # ファイル名を正規表現で変更する。perl製のrenameような。
  for i in {2..$#}; do
    local new=$(echo ${argv[${i}]} | sed $1)
    [[ -e ${argv[${i}]} && ${argv[${i}]} != ${new} ]] && mv "${argv[${i}]}" "${new}"
  done
}

function cc() { # ファイルの文字数を数える
  [[ -s $1 ]] && cat $1 | sed ':l;N;$!bl;s/\n//g' | wc -m
}
