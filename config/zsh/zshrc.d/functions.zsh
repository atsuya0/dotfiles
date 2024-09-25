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
  [[ -z ${commands[fzf]} ]] && return 1

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
    local -r ssid=$(netctl list | grep '*' | cut -d' ' -f2)
    [[ -z ${ssid} ]] && echo 'Not connected' && return 1
    sudo netctl restart ${ssid}
    return 0
  elif [[ -n "${options[(i)-s]}" ]]; then
    sudo netctl stop-all
    return 0
  fi

  [[ $# -ne 0 ]] && { sudo netctl start $1; return 0; }

  local -r ssid=$(netctl list | fzf --select-1)
  [[ -n ${ssid} ]] && sudo netctl start ${ssid// /}
}
function _wifi() {
  function ssid() {
    _values 'ssid' \
      $(netctl list)
  }
  _arguments \
    '-r[restart]' \
    '-s[stop-all]' \
    '1: :ssid'
}
compdef _wifi wifi

# ex
#   confirm date
#   confirm systemctl poweroff
function confirm() {
  local input
  while [[ ${input} != 'yes' && ${input} != 'no' ]]; do
    # printf '\ryes / no'
    echo 'yes / no'
    read input
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

set -euCo pipefail

function main() {
  :
}

main $@
EOF
  chmod +x "./${name}"
}

function new_py() {
  local -r name='x.py'
  [[ -f ./${name} ]] && return 1
cat << "EOF" > ./${name}
#!/usr/bin/env python3

def main():
    pass

if __name__ == '__main__':
    main()
EOF
  chmod +x "./${name}"
}

# $ crypt test.txt
# ファイルの暗号と復号を行う。暗号か復号はファイルの状態で自動で決める。
function crypt() {
  [[ -z ${commands[openssl]} ]] && { echo 'openssl is required'; return 1; }

  function encrypted() {
    [[ $(file $1 | cut -d' ' -f2-) == "openssl enc'd data with salted password" ]] \
      && return 0 || return 1
  }

  if encrypted $1; then
    openssl enc -d -aes-256-cbc -pbkdf2 -salt -in $1 -out "${1%.enc}"
  else
    openssl enc -e -aes-256-cbc -pbkdf2 -salt -in $1 -out "$1.enc"
  fi
}
function _crypt() {
  _files
}
compdef _crypt crypt

function md() { # multi displays
  [[ -z ${commands[xrandr]} ]] && return 1

  local -r primary=$(xrandr --listactivemonitors | sed '1d;s/[[:space:]][[:space:]] */ /g' | cut -d' ' -f5 | head -1)

  case $1 in
  'home' )
    local -r secondary=$(xrandr | grep ' connected' | cut -d' ' -f1 | grep -v ${primary})
    xrandr --output ${secondary} --left-of ${primary} --mode 1366x768
1920x1080
    return
  ;;
  'parents-home' )
    local -r secondary=$(xrandr | grep ' connected' | cut -d' ' -f1 | grep -v ${primary})
    xrandr --output ${secondary} --left-of ${primary} --mode 1360x768
    return
  ;;
  'off' )
    local -r secondary=$(xrandr --listactivemonitors | sed 1d | grep -v '*' | head -1 | sed 's/[[:space:]][[:space:]]*/ /g' | cut -d' ' -f5)
    [[ $(xrandr --listactivemonitors | wc -l) -gt 2 ]] \
      && xrandr --output ${secondary} --off
    return
  ;;
  esac

  [[ -z ${commands[fzf]} ]] && return 1
  local -r mode=$(xrandr | sed -n "/^${secondary}/,/^[^ ]/p" | sed '/^[^ ]/d;s/  */ /g' | cut -d' ' -f2 | fzf)
  [[ -n ${mode} ]] \
    && xrandr --output ${secondary} --left-of ${primary} --mode ${mode}
}
function _md() {
  _values \
    'args' \
    'home' \
    'parents-home' \
    'off'
}
compdef _md md

function rs() { # Remove spaces from file names.
  for file in $@; do
    #[[ -e ${file} && ${file} =~ ' ' ]] && mv "${file}" "${file// /}"
    [[ -e ${file} && ${file} =~ ' ' ]] && mv "${file}" $(echo ${file} | sed 's/ \+/_/g')
  done
}

function rn() { # Rename files using regular expression. Like perl's rename command.
  for i in {2..$#}; do
    local new=$(sed $1 <<< ${argv[${i}]})
    [[ -e ${argv[${i}]} && ${argv[${i}]} != ${new} ]] \
      && mv "${argv[${i}]}" "${new}"
  done
}

# $ mnt /dev/sdb3
function mnt() {
  [[ $# -eq 0 ]] && return 1
  local -r mount_path="${HOME}/mnt"

  if [[ -d ${mount_path} ]]; then
    [[ -z $(find ${mount_path} -maxdepth 0 -type d -empty) ]] \
      && return 1
  else
    mkdir ${mount_path}
  fi

  sudo mount $1 ${mount_path}
}

function umnt() {
  local -r mount_path="${HOME}/mnt"

  [[ -d ${mount_path} ]] || return 1
  sudo umount -R ${mount_path}
  rmdir ${mount_path}
}

function _vscode_extensions() {
  _values 'cmd' \
    'save' \
    'install'
}
compdef _vscode_extensions vscode_extensions.sh

function twitter_search() {
  [[ $# -eq 0 ]] && return 1

  local word query="$1%20"
  for word in ${argv[2,-1]}; do
    query="${query}AND%20${word}%20"
  done

  local -r user='%40fjdslkajfdlsajflds'
  xdg-open "https://twitter.com/search?q=${query}OR%20${user}&src=typd"
}

function chrome() {
  case $1 in
    '-s'|'--secret' )
      if [[ -n ${WSL_INTEROP} ]]; then
        '/mnt/c/Program Files/Google/Chrome/Application/chrome.exe' --new-window --incognito $(wslpath -w $2)
      else
        google-chrome-stable --new-window --incognito $2
      fi
    ;;
    * )
      if [[ -n ${WSL_INTEROP} ]]; then
        '/mnt/c/Program Files/Google/Chrome/Application/chrome.exe' $(wslpath -w $1)
      else
        google-chrome-stable $1
      fi
    ;;
  esac
}

function update() {
  local -r name=$(cat /etc/os-release | grep ^ID= | cut -d= -f2)
  case ${name} in
    'ubuntu' )
      echo 'sudo apt-get -y update && sudo apt-get -y upgrade'
      sudo apt-get -y update \
        && sudo apt-get -y upgrade
    ;;
    'arch' )
      echo '\e[31;1msudo pacman -Syu'
      sudo pacman -Syu
    ;;
  esac
}

function rm_orphan_pkgs() {
  echo '\e[31;1msudo pacman -Rsn $(pacman -Qdmq)'
  sudo pacman -Rsn $(pacman -Qdmq)
}

function clyrics() {
  #xsel | sed 's@<[^>]*>@\n@g' | grep -v '^$' | xsel -ib
  #xsel | sed 's@<[^>]*>@\n@g' | xsel -ib
  pbpaste | sed 's@<[^>]*>@\n@g' | pbcopy
}

#function kitty_view() {
#  [[ -z ${commands[fzf]} ]] && return 1
#
#tmux split-window -h kitty +kitten icat thumb_image_230517195327.jpg
#  ls | fzf \
#    --preview='kitty +kitten icat "{}"' \
#    --preview-window='right:80%' \
#    --bind='ctrl-v:toggle-preview'
#}
