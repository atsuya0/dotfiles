# .zlogin

() { # 存在しないディレクトリの記録を.saved_dirsから削除する
  [[ -n ${ZDOTDIR} ]] && local file=${ZDOTDIR}/.saved_dirs || local file=${HOME}/.saved_dirs
  [[ ! -s ${file} ]] && return

  # echo {} の処理で ~ が${HOME}に展開されて出力されるので、置換で戻す。
  cat ${file} | cut -d' ' -f3 | xargs -I{} sh -c "test -e {} || echo {}" | sed "s@${HOME}@~@" | xargs -I{} sed -i 's@.* {}$@@;/^$/d' ${file}
}

# .zshrc

function cds() { # pathに別名をつけて移動を早くする。

  [[ -n ${ZDOTDIR} ]] && local saved_dirs=${ZDOTDIR}/.saved_dirs || local saved_dirs=${HOME}/.saved_dirs
  # 記録ファイルがなければ作成
  [[ ! -e ${saved_dirs} ]] && find . -maxdepth 1 -type d -not -name '.*' -printf 'default %f ~/%f\n' > ${saved_dirs}
  local dir alias i action='change'

  for (( i=1; i <= $#; i++ )); do
    case ${argv[$i]} in
      '-t' ) # タグ
        (( i++ ))
        [[ -n ${argv[$i]} && ${argv[$i]} != -* ]] && local tag=${argv[$i]}
      ;;
      '-s' ) # 保存
        local skip=0
        [[ ${action} != 'change' ]] && echo 'option error' >&2 && return 1
        action='save'

        if [[ -n ${argv[$i+1]} && ${argv[$i+1]} != -* ]]; then
          alias=${argv[$i+1]} && (( skip++ ))
        else
          alias=$(basename ${PWD})
        fi

        if [[ -n ${argv[$i+2]} && ${argv[$i+2]} != -* ]]; then
          dir=${argv[$i+2]} && (( skip++ ))
        else
          dir=$(pwd)
        fi
        i=$(( $i + ${skip} )) # -s の引数の数だけループを飛ばす
      ;;
      '-l' ) # 一覧
        [[ ${action} != 'change' ]] && echo 'option error' >&2 && return 1
        action='list'
      ;;
      '-d' ) # 削除
        [[ ${action} != 'change' ]] && echo 'option error' >&2 && return 1
        action='delete'
        [[ -n ${argv[$i+1]} && ${argv[$i+1]} != -* ]] && alias=${argv[$i+1]} && (( i++ ))
      ;;
      '--delete-all' ) # 全削除
        [[ ${action} != 'change' ]] && echo 'option error' >&2 && return 1
        action='delete-all'
      ;;
      '-e' ) # 編集
        [[ ${action} != 'change' ]] && echo 'option error' >&2 && return 1
        action='edit'
      ;;
      '-h' ) # ヘルプ
        [[ ${action} != 'change' ]] && echo 'option error' >&2 && return 1
        action='help'
      ;;
      * )
        alias=${argv[$i]}
      ;;
    esac
  done

  # ファイルから別名とpathを切り出す
  if [[ ${action} == 'change' || ${action} == 'list' || ${action} == 'delete' ]]; then
    local file
    [[ -z ${tag} ]] \
      && file=$(cat ${saved_dirs} | cut -d' ' -f2-3) \
      || file=$(cat ${saved_dirs} | grep "^${tag} " | cut -d' ' -f2-3)
  fi

  function alias_exists() { # 既に登録されている別名か
    local alias
    for alias in $(cat ${saved_dirs} | cut -d' ' -f2); do
      [[ $1 == ${alias} ]] && echo 'alias already used' >&2 && return 1
    done
    return 0
  }

  function directory_exists() { # 既に登録されているdirectoryか
    local dir
    for dir in $(cat ${saved_dirs} | cut -d' ' -f3); do
      [[ $(echo $1 | sed "s@${HOME}@~@") == ${dir} ]] && echo 'directory already exists' >&2 && return 1
    done
    return 0
  }

  function check_file() { # ファイルを直接編集した場合、整合性がとれているか確認する。
    local message
    # 別名が重複
    local duplicateAliases=$(cat ${saved_dirs} | cut -d' ' -f2 | sort | uniq -d)
    [[ -n ${duplicateAliases} ]] && message="\e[31;1m[Duplicate aliases]\e[m\n${duplicateAliases}\n"

    # directoryが重複
    local duplicateDirectories=$(cat ${saved_dirs} | cut -d' ' -f3 | sort | uniq -d)
    [[ -n ${duplicateDirectories} ]] && message="${message}\e[31;1m[Duplicate directory]\e[m\n${duplicateDirectories}\n"

    # directoryではないものを登録していないか
    local dir incorrent
    for dir in $(cat ${saved_dirs} | cut -d' ' -f3 | sort | uniq); do
      [[ -d $(echo ${dir} | sed "s@~@${HOME}@") ]] || incorrent="${incorrent}${dir}\n"
    done
    [[ -n ${incorrent} ]] && message="${message}\e[31;1m[Not directories]\e[m\n${incorrent}" && incorrent=''

    local alias
    # 別名に/が含まれているか
    for alias in $(cat ${saved_dirs} | cut -d' ' -f2 | sort | uniq); do
      [[ ${alias} =~ '/' ]] && incorrent="${incorrent}${alias}\n"
    done
    [[ -n ${incorrent} ]] && message="${message}\e[31;1m[Alias contains \"/\"]\e[m\n${incorrent}"
    [[ -n ${message} ]] && echo -e ${message} | sed '/^$/d' >&2 && print -z 'cds -e'
  }

  case ${action} in
    'change' )
      if [[ -n ${alias} ]]; then
        dir=$(echo ${file} | grep "^${alias} " | head -1) \
      else
        type fzf &> /dev/null || return 1
        dir=$(echo ${file} | fzf --header='change directory' --preview='tree -C {}' --preview-window='right:hidden' --bind='ctrl-v:toggle-preview')
      fi
      [[ -n ${dir} ]] && eval cd $(echo ${dir} | cut -d' ' -f2)
    ;;
    'save' )
      [[ ${alias} =~ '/' ]] && echo 'alias: / cannot be used' >&2 && return 1
      alias_exists ${alias} || return 1
      [[ -d ${dir} ]] && dir=$(readlink -f ${dir}) || dir=$(pwd)
      directory_exists ${dir} || return 1
      echo "${tag:-default} ${alias} $(echo ${dir} | sed "s@${HOME}@~@")" >> ${saved_dirs}
    ;;
    'list' )
      [[ -z ${tag} ]] \
        && cat ${saved_dirs} | sort | xargs printf '\e[36m%s\e[m \e[37;1m%s\e[m \e[37m%s\e[m\n' \
        || echo ${file} | sort | xargs printf '\e[37;1m%s\e[m \e[37m%s\e[m\n'
    ;;
    'delete' )
      if [[ -z ${alias} ]]; then
        type fzf &> /dev/null || return 1
        alias=$(echo ${file} \
          | fzf --header='delete directory in the record' --preview='tree -C {}' --preview-window='right:hidden' --bind='ctrl-v:toggle-preview' \
          | cut -d' ' -f1)
      fi
      sed -i "/ ${alias} /d" ${saved_dirs}
    ;;
    'delete-all' )
      echo 'delete all?'
      select input in 'no' 'yes'; do
        case ${input} in
          'no' ) break ;;
          'yes' ) : >! ${saved_dirs} && break ;;
        esac
      done
    ;;
    'edit' )
      ${EDITOR} ${saved_dirs}
      check_file
    ;;
    'help' )
      echo '
      cds [別名]
      引数に別名を指定することで、移動する。
      引数を指定しない場合は、filterで選択する。

      -s 記録
      |   cds -s [別名] [path]
      |   pathの指定がなければ$(pwd)とする。別名の指定がなければカレントディレクトリ名とする。

      -l 一覧を出力

      -e 記録を直接編集

      -d 記録を削除
      |   cds -d [別名]
      |   引数を指定しない場合は、filterで選択する。

      --delete-all 全ての履歴を削除

      -t タグ
      |   保存するpathに対してtagを付けられる。
      ' | sed 's/^ *//;s/|/ /'
    ;;
  esac
}

function _cds() {
  [[ -n ${ZDOTDIR} ]] && local file=${ZDOTDIR}/.saved_dirs || local file=${HOME}/.saved_dirs

  _arguments \
    '-s[save]: :->t' \
    '-l[list]: :->t' \
    '-e[edit]: :->none' \
    '-d[delete]: :->alias' \
    '--delete-all[delete all]: :->none' \
    '-t[tag]: :->tag' \
    '-h[help]: :->none' \
    '*: :->alias'

  case ${state} in
    t )
      _arguments '-t[tag]: :->tag'
    ;;
    tag )
      _values 'tags' $(cat ${file} | cut -d' ' -f1 | sort | uniq)
    ;;
    alias )
      _values 'aliases' $(cat ${file} | cut -d' ' -f2-3 | sed 's/ /[/;s/$/]/')
    ;;
  esac
}

compdef _cds cds
