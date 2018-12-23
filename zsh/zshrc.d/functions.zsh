() {
  local -r dir="${ZDOTDIR}/zshrc.d/functions"
  local file
  [[ -d ${dir} && -z $(find ${dir} -maxdepth 0 -type d -empty) ]] || return 1
  for file in ${dir}/*.zsh; do
    source ${file}
  done
}

# The which command that does not find alias or function.
function cmd_exists() {
  [[ -n $(echo ${PATH//:/\\n} | xargs -I{} find {} -type f -name $1) ]] \
    && return 0
  return 1
}

function __src_to_dest__() {
  type fzf &> /dev/null || return 1

  local -r fzf_options=" \
    --preview='less {}' \
    --preview-window='right' \
    --bind='ctrl-v:toggle-preview'"

  local dest
  local -a src=()
  while (( $# > 0 )); do
    case $1 in
      '-c'|'--command' )
        [[ -z $2 || $2 =~ ^-+ ]] && return 1
        local cmd=$2
        shift 2
      ;;
      '-o'|'--option' )
        [[ -z $2 || $2 =~ ^-+ ]] && return 1
        local opt=$2
        shift 2
      ;;
      '-d'|'--dest' )
        [[ -z $2 || $2 =~ ^-+ ]] && return 1
        dest=$2
        shift 2
      ;;
      * )
        [[ -z $1 || $1 =~ ^-+ ]] && return 1
        src=($1 ${src[@]})
        shift 1
      ;;
    esac
  done

  [[ -z ${cmd} ]] && return 1

  if [[ ${#src[@]} -eq 0 ]]; then
    src=($(eval find -mindepth 1 $(ignore_absolute_paths) -print 2> /dev/null \
      | cut -c3- | eval fzf ${fzf_options}))
    [[ ${#src[@]} -eq 0 ]] && return 1
  fi

  [[ -z ${dest} ]] && dest=$( \
    eval find -mindepth 1 $(ignore_absolute_paths) -type d \
      -print 2> /dev/null \
    | cut -c3- | eval fzf --header="'${src[@]}'" ${fzf_options})

  [[ -n ${dest} ]] && eval ${cmd} "-${opt}" ${src[@]} -t ${dest}
}

function fcp() {
  local cmd='cp' opt='riv'
  case $1 in
    '-t'|'--target' )
      __src_to_dest__ -c ${cmd} -o ${opt} -d $2
    ;;
    * )
      __src_to_dest__ -c ${cmd} -o ${opt} $@
    ;;
  esac
}

function fmv() {
  local -r cmd='mv' opt='iv'
  case $1 in
    '-t'|'--target' )
      __src_to_dest__ -c ${cmd} -o ${opt} -d $2
    ;;
    * )
      __src_to_dest__ -c ${cmd} -o ${opt} $@
    ;;
  esac
}

function wifi() {
  local -A options
  zparseopts -D -A options -- r s

  if [[ -n "${options[(i)-r]}" ]]; then
    local -r ssid=$(netctl list | sed '/^\*/!d;s/[\* ]*//')
    [[ -z ${ssid} ]] && echo 'Not connected' && return 1
    sudo netctl restart ${ssid}
  elif [[ -n "${options[(i)-s]}" ]]; then
    sudo netctl stop-all
  else
    local -r ssid=$(netctl list | fzf --select-1)
    [[ -n ${ssid} ]] && sudo netctl start ${ssid// /}
  fi
}

# ex
#   interactive date
#   interactive systemctl poweroff
function interactive() {
  local input
  while [[ ${input} != 'yes' && ${input} != 'no' ]]; do
    # printf '\ryes / no'
    echo 'yes / no'
    read -s input
  done

  [[ ${input} == 'yes' ]] && eval $@
}

function bat() { # Battery
  local -r bat='/sys/class/power_supply/BAT1'
  [[ -e ${bat} ]] \
    && cat "${bat}/capacity" | sed 's/$/%/' \
    || echo 'No Battery'
}

function bak() { # Backup files with .bak after filename extension.
  local file

  case $1 in
  '-r' ) # remove .bak
    for file in $argv[2,-1]; do
      mv -i "${file}"  "${file%.bak}"
    done
  ;;
  * )
    for file in $@; do
      eval cp -ir "${file}{,.bak}"
    done
  ;;
  esac
}

function new_sh() {
  local -r name='x.sh'
  [[ -f ./${name} ]] && return 1
cat << "EOF" > ./${name}
#!/usr/bin/env bash

function main() {
}

main $@
EOF
  chmod +x ./${name}
}

function new_py() {
  local -r name='x.py'
  [[ -f ./${name} ]] && return 1
cat << "EOF" > ./${name}
#!/usr/bin/env python3

def main():

if __name__ == '__main__':
    main()
EOF
  chmod +x ./${name}
}

# Bluetooth tethering
# Do not use the anaconda's dbus-send.
# The AC_CF_85_B7_9D_9A is MAC address of the smartphone。
function bt() {
  local -r ADDR='AC:CF:85:B7:9D:9A'

  systemctl is-active bluetooth &> /dev/null \
    || sudo systemctl start bluetooth.service
  () {
    echo 'power on'
    sleep 1
    echo "connect $1"
    sleep 3
    echo 'quit'
  } ${ADDR} | bluetoothctl

  /usr/bin/dbus-send --system --type=method_call --dest=org.bluez \
    /org/bluez/hci0/dev_${ADDR//:/_} org.bluez.Network1.Connect string:'nap' \
    && sleep 1 \
    && sudo dhcpcd bnep0
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

function md() { # multi displays
  type xrandr &> /dev/null || return 1
  local -r primary=$(xrandr --listactivemonitors | sed '1d;s/  */ /g' | cut -d' ' -f5 | head -1)
  local -r second=$(xrandr | grep ' connected' | cut -d' ' -f1 | grep -v ${primary})

  case $1 in
  'school' )
    xrandr --output ${second} --left-of ${primary} --mode 1600x900
    return
  ;;
  'home' )
    xrandr --output ${second} --left-of ${primary} --mode 1366x768
    return
  ;;
  'off' )
    [[ $(xrandr --listactivemonitors | wc -l) -gt 2 ]] \
      && xrandr --output ${second} --off
    return
  ;;
  esac

  type fzf &> /dev/null || return 1
  local -r mode=$(xrandr | sed -n "/^${second}/,/^[^ ]/p" | sed '/^[^ ]/d;s/  */ /g' | cut -d' ' -f2 | fzf)
  [[ -n ${mode} ]] \
    && xrandr --output ${second} --left-of ${primary} --mode ${mode}
}
function _md() {
  _values \
    'args' \
    'school' \
    'home' \
    'off'
}
compdef _md md

function rs() { # Remove spaces from file names.
  for file in $@; do
    [[ -e ${file} && ${file} =~ ' ' ]] && mv "${file}" "${file// /}"
  done
}

function rn() { # Rename files using regular expression. Like perl's rename command.
  for i in {2..$#}; do
    local new=$(sed $1 <<< ${argv[${i}]})
    [[ -e ${argv[${i}]} && ${argv[${i}]} != ${new} ]] \
      && mv "${argv[${i}]}" "${new}"
  done
}

function crawl() {
  type crawl-img &> /dev/null || return 1
  type notify-send &> /dev/null || return 1
  [[ $# -eq 0 ]] && return 1

  crawl-img -f $1
  notify-send 'Image downloading is complete.'
}

function ct() {
  local -A options
  zparseopts -D -A options -- I X: d: -help

  if [[ -n "${options[(i)--help]}" ]]; then
    echo '-I'
    echo '-X [method]'
    echo '-d {"id": 1, "name": "taro"}'
    echo '$1 is path'

    return
  fi

  local data method
  [[ -n "${options[(i)-X]}" ]] && method="${options[-X]}"
  [[ -n "${options[(i)-d]}" ]] && data="-d ${options[-d]}"

  local -ar methods=('GET' 'POST' 'PUT' 'DELETE')
  [[ -z ${method} ]] \
    && type fzf &> /dev/null \
    && method=$(print -C 1 ${methods[@]} | fzf)
  curl ${options[(i)-I]} -X ${method:-GET} ${data} \
    -H "'Content-Type: application/json'" "http://localhost:9000$1"
}

function _ct() {
  function methods() {
    _values 'methods' \
      'GET' 'POST' 'PUT' 'DELETE'
  }
  _arguments \
    '-I[head]' \
    '-X[method]: :methods' \
    '--help[help]'
}
compdef _ct ct

# mnt /dev/sdb1
# mnt /dev/sdb1 ~/mnt
function mnt() {
  [[ $# -eq 0 ]] && return 1

  local -r mount_path="${HOME}/mnt"
  if [[ -d ${2:=${mount_path}} ]]; then
    [[ -z $(find $2 -maxdepth 0 -type d -empty) ]] \
      && return 1
  else
    mkdir $2
  fi

  sudo mount $1 $2
}

function umnt() {
  local -r mount_path="${HOME}/mnt"
  sudo umount -R ${1:=${mount_path}}
  rmdir $1
}

function vscode_extensions() {
  type code &> /dev/null || return 1

  local -r store="${DOTFILES:-${HOME}}/vscode/extensions.txt"
  local -r error_msg="extension is not saved\nplease execute: $0 save"

  case $1 in
    'save' )
      local -r extensions=$(code --list-extensions)
      [[ -e ${store} ]] \
        && diff -s ${store} <(echo ${extensions[@]}) > /dev/null \
        && return
      echo ${extensions} >! ${store}
    ;;
    'install' )
      [[ -e ${store} ]] || { echo ${error_msg}; return 1; }
      cat ${store} | while read -r extension; do
        code --install-extension ${extension}
      done
    ;;
    * )
      [[ -e ${store} ]] || { echo ${error_msg}; return 1; }
      cat ${store}
    ;;
  esac
}
function _vscode_extensions() {
  _values 'cmd' \
    'save' \
    'install'
}
compdef _vscode_extensions vscode_extensions

function ssid() {
  type wpa_cli &> /dev/null || return 1

  local -r interface=$(command ip -o link show up | grep -v 'lo:' | tr -d ' ' | cut -d: -f2)
  { echo 'status'; echo 'quit'; } \
    | wpa_cli -i ${interface} | grep '^ssid=' | cut -d= -f2
}
