[[ -n $TMUX ]] && return


() { # 存在しないディレクトリの記録を.saved_dirsから削除する
  [[ -n ${ZDOTDIR} ]] && local file=${ZDOTDIR}/.saved_dirs || local file=${HOME}/.saved_dirs
  [[ ! -s ${file} ]] && return

  # echo {} の処理で ~ が${HOME}に展開されて出力されるので、置換で戻す。
  cat ${file} | cut -d' ' -f3 | xargs -I{} sh -c "test -e {} || echo {}" | sed "s@${HOME}@~@" | xargs -I{} sed -i 's@.* {}$@@;/^$/d' ${file}
}

() { # ゴミ箱に移動してから1ヶ月経つファイル・ディレクトリを削除
  local trash="${HOME}/.Trash"
  [[ ! -s ${trash} ]] && return

  for file in $(command ls ${trash});do
    stat --format=%Z "${trash}/${file}" \
      | xargs -I{} test {} -le $(date --date '1 month ago' +%s) \
      && command rm -fr "${trash:-abcdef}/${file:-abcdef}"
  done
}

# Xを起動。ログイン後にディスプレイマネージャを使わずに、X window managerを起動する。
# [[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx
