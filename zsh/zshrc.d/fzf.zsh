# fzf (A command-line fuzzy finder) 用の設定

# <C-y>で文字列をコピー
export FZF_DEFAULT_OPTS="-m --height=80% --reverse --exit-0 --bind 'ctrl-y:execute-silent(echo {} | xsel -ib)+abort'"
# <C-v>で見切れたコマンドを表示
export FZF_CTRL_R_OPTS="--preview='echo {}' --preview-window=down:3:hidden:wrap --bind 'ctrl-v:toggle-preview'"
# FZF_DEFAULT_COMMAND FZF_ALT_C_COMMAND FZF_ALT_C_OPTS

() { # fzfの拡張を読み込む
  typeset -r fzf_dir='/usr/share/fzf'
  readonly local  keybind="${fzf_dir}/key-bindings.zsh"
  typeset -r completion="${fzf_dir}/completion.zsh"
  [[ -f ${keybind} ]] && source "${keybind}"
  [[ -f ${completion} ]] && source "${completion}"
}

function __fzf_cd_widget__() {
  # ALT_Cにbindされてるwidgetを上書きしている。
  # 現階層以下のディレクトリからfzfを使って選び移動する。

  local dir
  for dir in ${ignore_absolute_pathes}; do
    local argument="${argument} -path ${dir/$(pwd)/.} -prune -o"
  done

  dir=$(eval find -mindepth 1 ${argument} -type d -print 2> /dev/null \
    | cut -c3- | fzf --select-1 --preview='tree -C {} | head -200' --preview-window='right:hidden' --bind='ctrl-v:toggle-preview')
  eval builtin cd ${dir:-.}

  _path_prompt
  zle reset-prompt
}
zle -N __fzf_cd_widget__
bindkey '\ec' __fzf_cd_widget__
