() {
  typeset -r dir="${ZDOTDIR}/zshrc.d/functions"
  local file
  [[ -d ${dir} && -z $(find ${dir} -maxdepth 0 -type d -empty) ]] || return 1
  for file in ${dir}/*.zsh; do
    source ${file}
  done
}

function cmd_exists() { # The which command that does not find alias or function.
  [[ -n $(echo ${PATH//:/\\n} | xargs -I{} find {} -type f -name $1) ]] \
    && return 0
  return 1
}


function vim(){ # Choose files to open by fzf.
  function editor() {
    if cmd_exists nvim &> /dev/null; then
      echo "nvim $@"
    elif cmd_exists vim &> /dev/null; then
      echo "vim $@"
    else
      echo "vi $@"
    fi
  }

  function ignore_filetypes() {
    typeset -r ignore_filetypes=(
      pdf png jpg jpeg mp3 mp4 tar.gz zip
    )
    local filetype
    for filetype in ${ignore_filetypes}; do
      echo '-name' "\*${filetype}" '-prune -o'
    done
  }

  function ignore_dirs() {
    typeset -r ignore_dirs=(
      .git node_modules vendor target gems cache google-chrome
    )
    local dir
    for dir in ${ignore_dirs}; do
      echo '-path' "\*${dir}\*" '-prune -o'
    done
  }

  [[ $# -ne 0 ]] && eval $(editor $@) && return 0

  type fzf &> /dev/null || return 1
  typeset -r files=$(eval find \
    $(ignore_filetypes) $(ignore_dirs) $(ignore_absolute_paths) -type f -print \
    | cut -c3- \
    | fzf --select-1 --preview='less {}' \
      --preview-window='right:hidden' --bind='ctrl-v:toggle-preview')
  [[ -n ${files} ]] && eval $(editor ${files})
}


function __sources_to_dir__() {
  [[ $# -ne 1 ]] && return 1
  type fzf &> /dev/null || return 1
  typeset -r cmd=$1

  typeset -r fzf_options="--select-1 \
    --preview='less {}' \
    --preview-window='right' \
    --bind='ctrl-v:toggle-preview'"

  typeset -r src=($(eval find -mindepth 1 $(ignore_absolute_paths) -print 2> /dev/null \
    | cut -c3- | eval fzf ${fzf_options}))
  [[ ${#src[@]} -eq 0 ]] && return

  typeset -r dir=$(eval find -mindepth 1 $(ignore_absolute_paths) -type d -print 2> /dev/null \
    | cut -c3- | eval fzf --header="'${src[@]}'" ${fzf_options})

  [[ -n ${dir} ]] && eval ${cmd} ${src[@]} -t ${dir}
}

function fcp() {
  __sources_to_dir__ 'cp -riv'
}

function fmv() {
  __sources_to_dir__ 'mv -iv'
}

function hist() {
  [[ $# -eq 0 ]] && history -i 1 || history $@
}

function wifi() {
  local -A options
  zparseopts -D -A options -- r s

  if [[ -n "${options[(i)-r]}" ]]; then
    typeset -r ssid=$(netctl list | sed '/^\*/!d;s/[\* ]*//')
    [[ -z ${ssid} ]] && echo 'Not connected' && return 1
    sudo netctl restart ${ssid}
  elif [[ -n "${options[(i)-s]}" ]]; then
    sudo netctl stop-all
  else
    typeset -r ssid=$(netctl list | fzf --select-1)
    [[ -n ${ssid} ]] && sudo netctl start ${ssid// /}
  fi
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
  local name='tmp.sh'
  [[ -f ./${name} ]] && return 1
  echo '#!/usr/bin/bash\n' > ./${name}
  chmod +x ./${name}
}

function new_py() {
  local name='tmp.py'
  [[ -f ./${name} ]] && return 1
cat << "EOF" > ./${name}
#!/usr/bin/python3

def main():

if __name__ == '__main__':
    main()
EOF
  chmod +x ./${name}
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
  typeset -r primary=$(xrandr --listactivemonitors | sed '1d;s/  */ /g' | cut -d' ' -f5 | head -1)
  typeset -r second=$(xrandr | grep ' connected' | cut -d' ' -f1 | grep -v ${primary})

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
  typeset -r mode=$(xrandr | sed -n "/^${second}/,/^[^ ]/p" | sed '/^[^ ]/d;s/  */ /g' | cut -d' ' -f2 | fzf)
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

function rn() { # Rename files using regular expression. Like Perl's rename command.
  for i in {2..$#}; do
    local new=$(sed $1 <<< ${argv[${i}]})
    [[ -e ${argv[${i}]} && ${argv[${i}]} != ${new} ]] && mv "${argv[${i}]}" "${new}"
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
  zparseopts -D -A options -- I X: -help

  if [[ -n "${options[(i)--help]}" ]]; then
    echo '-I'
    echo '-X [method]'
    echo '$1 is path'

    return
  fi

  local method
  [[ -n "${options[(i)-X]}" ]] && method="${options[-X]}"

  typeset -r methods=('GET' 'POST' 'PUT' 'DELETE')
  [[ -z ${method} ]] \
    && fzf &> /dev/null \
    && method=$(echo ${methods} | sed 's/ /\n/g' | fzf)

  curl ${options[(i)-I]} -X ${method:-GET} "http://localhost:9000$1"
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

  typeset -r m_path="${HOME}/mnt"
  if [[ -d ${2:=${m_path}} ]]; then
    [[ -z $(find $2 -maxdepth 0 -type d -empty) ]] \
      && return 1
  else
    mkdir $2
  fi

  sudo mount $1 $2 \
    && sudo chown -R $(whoami) $2
}

function umnt() {
  typeset -r m_path="${HOME}/mnt"
  sudo umount -R ${1:=${m_path}}
  rmdir $1
}
