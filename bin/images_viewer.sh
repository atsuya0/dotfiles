#!/opt/homebrew/bin/zsh

set -eCo pipefail

function initialize() {
  tput smcup
  tput civis
  stty -echo cbreak
}

function cleanup() {
  tput rmcup
  tput cnorm
  tput sgr0
  stty sane
}

function main() {
  [[ -z ${commands[chafa]} ]] && { echo 'chafa is required'; return 1; }
  [[ -z ${commands[eza]} ]] && { echo 'eza is required'; return 1; }
  [[ -z ${commands[identify]} ]] && { echo 'identify is required'; return 1; }

  cd "${1:-.}"

  local current_index=1
  local -a files=($(eza -1f | xargs -I{} zsh -c 'identify {} &> /dev/null && echo {}'))

  [[ ${#files} == 0 ]] && return 1

  local -a fav_list
  [[ -f ./favorites.txt ]] && fav_list=($(cat ./favorites.txt))

  while true; do
    # 予期せず標準入力を消費するので/dev/nullに接続する
    chafa --clear -f sixel --scale max --align mid,mid "${files[${current_index}]}" < /dev/null
    echo "${current_index} / ${#files}"
    echo ${fav_list}
    read -k 1 input
    case ${input} in
      ' ' )
        [[ ${current_index} -ne ${#files} ]] && (( current_index++ ))
      ;;
      'j' )
        [[ ${current_index} -ne ${#files} ]] && (( current_index++ ))
      ;;
      'k' )
        [[ ${current_index} -ne 1 ]] && (( current_index-- ))
      ;;
      'l' )
        [[ ${current_index} -le (( ${#files} - 5 )) ]] && (( current_index += 5 ))
      ;;
      'h' )
        [[ ${current_index} -gt 5 ]] && (( current_index -= 5 ))
      ;;
      'f' )
        fav_list+=(${current_index})
        fav_list=(${(nu)fav_list})
      ;;
      'F' )
        fav_list=(${fav_list:#${current_index}})
      ;;
      'J' )
        local fav_index
        for fav_index in ${fav_list}; do
          [[ ${current_index} -lt ${fav_index} ]] \
            && [[ ${current_index} -ne ${#files} ]] \
            && current_index=${fav_index} \
            && break
        done
      ;;
      'K' )
        local fav_index
        for fav_index in ${(On)fav_list}; do
          [[ ${current_index} -gt ${fav_index} ]] \
            && [[ ${current_index} -ne 1 ]] \
            && current_index=${fav_index} \
            && break
        done
      ;;
      'q' )
        break
      ;;
    esac
  done

  [[ ${#fav_list} == 0 ]] || echo ${fav_list[@]} >! ./favorites.txt
}

trap cleanup EXIT INT TERM
initialize
main $1
