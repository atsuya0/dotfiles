# 補完結果をできるだけ詰める
setopt list_packed
# カッコの対応などを自動的に補完
setopt auto_param_keys
# ディレクトリ名の補完で末尾の/を自動的に付加し次の補完に備える
setopt auto_param_slash
# ファイル名の展開でディレクトリに一致した場合末尾に/を付加する
#setopt mark_dirs
# カーソル位置で補完する。
setopt complete_in_word
# globを展開しないで候補の一覧から補完する。
setopt glob_complete
# 辞書順ではなく数字順に並べる。
setopt numeric_glob_sort
# --prefix=~/localというように「=」の後でも
# 「~」や「=コマンド」などのファイル名展開を行う。
setopt magic_equal_subst

# 補完時にハイライト tab,C-n,C-f,C-p,C-b
zstyle ':completion:*:default' menu select
# 補完で大文字にも一致
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
# 区切り文字
zstyle ':completion:*' list-separator '->'
# 上記を有効
zstyle ':completion:*:manuals' separate-sections true
# 補完候補に色を付ける
zstyle ':completion:*' list-colors eval $(dircolors -b)
# 説明を緑の太字で表示
zstyle ':completion:*' format '%B%F{green}%d%f%b'
# 補完しないファイル
zstyle ':completion:*:*files' ignored-patterns '*mp3' '.mp4'
# グループ名を表示
zstyle ':completion:*' group-name ''
# キャッシュ
zstyle ':completion:*' use-cache yes
# 詳細
zstyle ':completion:*' verbose yes
# tabを挿入しない
zstyle ':completion:*' insert-tab false

fpath=(${ASDF_DIR}/completions $fpath)

LOCAL_COMPLETIONS_DIR="${HOME}/.zsh_completions"
mkdir -p ${LOCAL_COMPLETIONS_DIR}
fpath=(${LOCAL_COMPLETIONS_DIR} $fpath)

if command -v aqua &> /dev/null; then source <(aqua completion zsh); fi

() {
  [[ -z ${commands[yq]} ]] && return
  yq --version | grep -q 'mikefarah' || return
  local -r yq_completion="${LOCAL_COMPLETIONS_DIR}/_yq"
  # yq自体を更新したときに更新
  [[ ! -e ${yq_completion} ]] \
    && yq shell-completion zsh > ${yq_completion}
}

() {
  [[ -z ${commands[poetry]} ]] && return
  local -r poetry_completion="${LOCAL_COMPLETIONS_DIR}/_poetry"
  # poetry自体を更新したときに更新
  [[ ! -e ${poetry_completion} ]] \
    && poetry completions zsh > ${poetry_completion}
}

autoload bashcompinit && bashcompinit
autoload -Uz compinit && compinit

() {
  local -r completion="${GCP_PATH}/completion.zsh.inc"
  [[ -f ${completion} ]] && source ${completion}
}
() {
  local -r aws_completer='/usr/local/bin/aws_completer'
  [[ -f ${aws_completer} ]] && complete -C ${aws_completer} aws
}

if [[ -n ${ASDF_DIR} ]]; then
  [[ -n ${commands[terraform]} ]] \
    && complete -o nospace -C ${ASDF_DIR}/shims/terraform terraform
fi

# if [[ -n ${AQUA_ROOT_DIR} ]]; then
#   [[ -n ${commands[terraform]} ]] \
#     && complete -o nospace -C ${AQUA_ROOT_DIR}/bin/terraform terraform
# fi

[[ -n ${commands[kubectl]} ]] && source <(kubectl completion zsh)
[[ -n ${commands[kubectl-argo-rollouts]} ]] && source <(kubectl-argo-rollouts completion zsh)
[[ -n ${commands[helm]} ]] && source <(helm completion zsh)
[[ -n ${commands[kind]} ]] && source <(kind completion zsh)
[[ -n ${commands[pack]} ]] && source $(pack completion --shell zsh)
[[ -n ${commands[gh]} ]] && eval $(gh completion -s zsh)
[[ -n ${commands[gh]} ]] && eval $(gh completion -s zsh)
