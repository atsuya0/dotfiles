#!/opt/homebrew/bin/zsh

set -eCo pipefail

function main() {
  [[ -z ${commands[chafa]} ]] && { echo 'chafa is required'; return 1; }
  [[ -z ${commands[eza]} ]] && { echo 'eza is required'; return 1; }
  [[ -z ${commands[identify]} ]] && { echo 'identify is required'; return 1; }

  cd "${1:-.}"

  local current_index=1
  local -a files=($(eza -1f | xargs -I{} zsh -c 'identify {} &> /dev/null && echo {}'))

  [[ ${#files} == 0 ]] && return 1

  while true; do
    chafa --clear -f sixel --scale max --align mid,mid "${files[${current_index}]}"
    read -k 1 input
    case ${input} in
      ' ' )
        (( current_index++ ))
      ;;
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

main $1
