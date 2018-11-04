() {
  local dir="${ZDOTDIR}/zshrc.d/functions" file
  [[ -d ${dir} && -z $(find ${dir} -maxdepth 0 -type d -empty) ]] || return 1
  for file in ${dir}/*.zsh; do
    source ${file}
  done
}

function wifi() {
  if [[ $1 == '-r' ]]; then # 再始動
    local ssid=$(netctl list | sed '/^\*/!d;s/[\* ]*//')
    [[ -z ${ssid} ]] && echo 'Not connected' && return 1
    sudo netctl restart ${ssid}
  elif [[ $1 == '-s' ]]; then
    sudo netctl stop-all
  elif type fzf &> /dev/null && ! netctl list | grep '^*' &> /dev/null; then
    local ssid=$(netctl list | fzf --select-1)
    [[ -n ${ssid} ]] && sudo netctl start ${ssid// /}
  fi
}


function cmd_exists(){ # 関数やaliasに囚われないtype,which。 vim()で使う。
  [[ -n $(echo ${PATH//:/\\n} | xargs -I{} find {} -type f -name $1) ]] \
    && return 0
  return 1
}

# The amount of transferred data after turning on the power.
function dtr() {
  cat /proc/net/dev | awk \
    '{if(match($0, /wlp4s0/)!=0) print "Wifi        : Receive",$2/(1024*1024),"MB","|","Transmit",$10/(1024*1024),"MB"} \
    {if(match($0, /bnep0/)!=0) print "Bluetooth Tethering : Receive",$2/(1024*1024),"MB","|","Transmit",$10/(1024*1024),"MB"}'
}


# ex) interactive systemctl poweroff
function interactive() {
  local input
  while [[ ${input} != 'yes' && ${input} != 'no' ]]; do
    printf '\ryes / no'
    read -s input
  done

  [[ ${input} == 'yes' ]] && command $@
}

function bat() { # Battery
  typeset -r bat='/sys/class/power_supply/BAT1'
  [[ -e ${bat} ]] \
    && cat "${bat}/capacity" | sed 's/$/%/' \
    || echo 'No Battery'
}

function bak() { # Backup files with .bak after filename extension.
  local file

  case $1 in
  '-r' ) # .bakを取り除く
    for file in $argv[2,-1]; do
      mv -i "${file}"  "${file%.bak}"
    done
  ;;
  * ) # ファイル名の末尾に.bakをつけた複製を作成する
    for file in $@; do
      eval cp -ir "${file}{,.bak}"
    done
  ;;
  esac
}

function init_test() {
  [[ -f ./test.sh ]] && return 1
  echo '#!/usr/bin/bash\n' > ./test.sh
  chmod +x ./test.sh
}

# Bluetooth tethering
# Do not use the anaconda's dbus-send.  The AC_CF_85_B7_9D_9A is MAC address of the smartphone。
function bt() {
  typeset -r ADDR='AC:CF:85:B7:9D:9A'

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
  local primary=$(xrandr --listactivemonitors | sed '1d;s/  */ /g' | cut -d' ' -f5 | head -1)
  local second=$(xrandr | grep ' connected' | cut -d' ' -f1 | grep -v ${primary})

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
  local mode=$(xrandr | sed -n "/^${second}/,/^[^ ]/p" | sed '/^[^ ]/d;s/  */ /g' | cut -d' ' -f2 | fzf)
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

function rn() { # Rename files using regular expression. Like Perl's rename.
  for i in {2..$#}; do
    local new=$(sed $1 <<< ${argv[${i}]})
    [[ -e ${argv[${i}]} && ${argv[${i}]} != ${new} ]] && mv "${argv[${i}]}" "${new}"
  done
}

function cc() { # Character Counter
  [[ -s $1 ]] && cat $1 | sed ':l;N;$!bl;s/\n//g' | wc -m
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

function fonts() {
  for i in {$(($1 * 1000))..$(($1 * 1000 + 2000))}; do
    echo -n -e "$(printf '\\u%x' $i) "
  done
}

function crawl() {
  type crawl-img &> /dev/null || return 1
  type notify-send &> /dev/null || return 1
  [[ $# -eq 0 ]] && return 1

  crawl-img -f $1
  notify-send 'Image downloading is complete.'
}
