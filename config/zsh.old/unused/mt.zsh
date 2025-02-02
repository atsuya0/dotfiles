# .zlogin
() { # ゴミ箱に移動してから1ヶ月経つファイル・ディレクトリを削除
  typeset -r trash="${HOME}/.Trash"
  [[ ! -s ${trash} ]] && return

  for file in $(command ls ${trash});do
    stat --format=%Z "${trash}/${file}" \
      | xargs -I{} test {} -le $(date --date '1 month ago' +%s) \
      && command rm -fr "${trash:-abcdef}/${file:-abcdef}"
  done
}

# .zshrc

function mt() { # ファイルをゴミ箱に入れる。 別途スクリプトで自動でゴミを消す。
  typeset -r trash="${HOME}/.Trash"
  typeset -r fzf_option="--preview-window='right:hidden' --bind='ctrl-v:toggle-preview'"
  [[ -s ${trash} ]] || mkdir ${trash}

  if [[ $1 == '-r' ]]; then # ゴミ箱からファイルを拾う
    type fzf &> /dev/null || return
    command ls -r ${trash} \
      | eval "fzf --header='move files in the trash to the current directory' \
      --preview=\"file ${trash}/{} | sed 's/^.*: //'; du -hs ${trash}/{} | cut -f1; echo '\n'; less ${trash}/{}\" \
      ${fzf_option}" | xargs -I{} sh -c "mv \"${trash}/{}\"  \"./\$(echo {} | cut -d_ -f3-)\""

  elif [[ $1 == '-d' ]]; then # ゴミ箱のファイルを焼却
    type fzf &> /dev/null || return
    command ls -r ${trash} \
      | eval "fzf --header='delete files in the trash' \
      --preview=\"file ${trash}/{} | sed 's/^.*: //'; du -hs ${trash}/{} | cut -f1; echo '\n'; less ${trash}/{}\" \
      ${fzf_option}" | xargs -p -I{} rm -r "${trash}/{}"

  elif [[ $1 == '-l' ]]; then # ゴミ一覧
    ls -r ${trash}
  elif [[ $1 == '-s' ]]; then # ゴミの量
    du -hs ${trash} | cut -f1
  else
    [[ $# -eq 0 ]] && type fzf &> /dev/null \
      && set $(command ls -A ./ | sed "/^${trash##*/}$/"d \
      | eval "fzf --header='move files in the current directory to the trash' \
      --preview=\"file {} | sed 's/^.*: //'; du -hs {} | cut -f1; less {}\" ${fzf_option}") \
      > /dev/null && [[ $# -eq 0 ]] && return

    echo $@ | tr -d '\n' |  xargs -d' ' -I{} sh -c "mv {} \"${trash}/\$(date +%F_%T_)\$(basename {})\""

  fi
}

function _mt() {
  typeset -r trash="${HOME}/.Trash"

  _arguments \
    '-r[restore]: :->trash' \
    '-d[delete]: :->trash' \
    '-l[list]: :->list' \
    '-s[size]: :->none' \
    '*: :->files'

  case "${state}" in
    list )
      _arguments \
        '-days[? days ago]: :->days' \
        '-reverse[reverse]: :->none'
    ;;
    trash )
      _values 'files in trash' $(command ls -Ar ${trash})
      # _files -W ${trash}
    ;;
    files )
      _files
    ;;
  esac
}
