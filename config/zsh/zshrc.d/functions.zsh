function ignore_absolute_paths() {
  local -ar paths=(
    "${HOME}/Trash"
    "${HOME}/.npm"
    "${GOPATH}/pkg"
    "${GOPATH}/src"
  )
  local IFS=$'\n'

  echo "${paths[*]}" \
    | grep "^$(pwd)" \
    | sed "s@$(pwd)@.@;s/.*/-path & -prune -o/g"
}

function ignore_dirs() {
  local -ar ignore_dirs=(
    '.git'
    '.terraform'
    'node_modules'
  )
  print -C 1 ${ignore_dirs[@]} \
    | sed 's/.*/-path \\*&\\* -prune -o/'
}

function ignore_filetypes() {
  local -ar ignore_filetypes=(
    'pdf' 'png' 'jpg' 'jpeg' 'mp3' 'mp4' 'tar.gz' 'zip'
  )
  print -C 1 ${ignore_filetypes[@]} \
    | sed 's/.*/-name \\*& -prune -o/'
}

# The which command that does not find alias or function.
function cmd_exists() {
  [[ -n $(echo ${PATH//:/\\n} | xargs -I{} find {} -type f -name $1) ]] \
    && return 0
  return 1
}

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

function clyrics() {
  pbpaste | sed 's@<[^>]*>@\n@g' | pbcopy
}

function timer() {
  for i in {1..$(expr ${1:-1} \* 60)}; do
    echo "$(expr $i / 60)m $(expr $i % 60)s"
    sleep 1
    echo '\x1b[2A'
  done
  osascript -e 'display notification "Finished"'
}

function iv() {
  [[ -n ${KITTY_LISTEN_ON} ]] && { iv_on_kitty; return; }
  [[ -n ${WEZTERM_UNIX_SOCKET} ]] && { iv_on_wezterm; return; }
}

function iv_on_kitty() {
  [[ -z ${commands[kitten]} ]] && { echo 'kitten is required'; return 1; }
  [[ -z ${commands[eza]} ]] && { echo 'eza is required'; return 1; }
  [[ -z ${commands[identify]} ]] && { echo 'identify is required'; return 1; }

  local current_index=1
  local -a files=($(eza -1f | xargs -I{} zsh -c 'identify {} &> /dev/null && echo {}'))

  while true; do
    kitten icat --clear
    kitten icat --place $(tput cols)x$(tput lines)@0x0 --align left --scale-up ${files[${current_index}]}
    read -k 1 input
    case ${input} in
      'j' )
        (( current_index++ ))
      ;;
      'k' )
        [[ ${current_index} -ne 1 ]] && (( current_index-- ))
      ;;
      'q' )
        break
      ;;
    esac
  done
  kitten icat --clear
}

function iv_on_wezterm() {
  [[ -z ${commands[chafa]} ]] && { echo 'chafa is required'; return 1; }
  [[ -z ${commands[eza]} ]] && { echo 'eza is required'; return 1; }
  [[ -z ${commands[identify]} ]] && { echo 'identify is required'; return 1; }

  local current_index=1
  local -a files=($(eza -1f | xargs -I{} zsh -c 'identify {} &> /dev/null && echo {}'))

  while true; do
    chafa -f sixel --scale max ${files[${current_index}]}

    read -k 1 input
    case ${input} in
      'j' )
        (( current_index++ ))
      ;;
      'k' )
        [[ ${current_index} -ne 1 ]] && (( current_index-- ))
      ;;
      'q' )
        break
      ;;
    esac
  done
}

() {
  local -r dir="${ZDOTDIR}/zshrc.d/functions"
  local file
  [[ -d ${dir} && -z $(find ${dir} -maxdepth 0 -type d -empty) ]] || return 1
  for file in ${dir}/*.zsh; do
    source ${file}
  done
}
