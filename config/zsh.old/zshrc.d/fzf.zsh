# fzf (A command-line fuzzy finder) 用の設定

[[ -n ${commands[rg]} ]] && export FZF_DEFAULT_COMMAND='rg'
# <C-y>で文字列をコピー
[[ ${OSTYPE} =~ 'darwin' ]] \
  && export FZF_DEFAULT_OPTS="-m --height=80% --reverse --exit-0 --bind 'ctrl-y:execute-silent(echo {} | execute-silent)+abort'" \
  || export FZF_DEFAULT_OPTS="-m --height=80% --reverse --exit-0 --bind 'ctrl-y:execute-silent(echo {} | xsel -ib)+abort'"
# <C-v>で見切れたコマンドを表示
export FZF_CTRL_R_OPTS="--preview='echo {}' --preview-window=down:3:hidden:wrap --bind 'ctrl-v:toggle-preview'"

() { # fzfの拡張を読み込む
  if [[ -n ${WSL_INTEROP} ]]; then
    local -r fzf_directory='/usr/share/doc/fzf/examples'
  elif [[ ${OSTYPE} == 'linux-gnu' ]]; then
    local -r fzf_directory='/usr/share/fzf'
  elif [[ ${OSTYPE} =~ 'darwin' ]]; then
    local -r fzf_directory="${HOMEBREW_PREFIX}/opt/fzf/shell"
  fi
  local -r keybind="${fzf_directory}/key-bindings.zsh"
  local -r completion="${fzf_directory}/completion.zsh"
  [[ -f ${keybind} ]] && source ${keybind}
  [[ -f ${completion} ]] && source ${completion}
}

# function __fzf_cd_widget__() {
#   # ALT_Cにbindされてるfzfが用意しているwidgetを上書きしている。
#   # 現階層以下のディレクトリからfzfを使って選び移動する。
#
#   local -r dir=$(eval find -mindepth 1 $(ignore_absolute_paths) -type d -print 2> /dev/null \
#     | cut -c3- | fzf --select-1 --preview='tree -C {} | head -200' --preview-window='right:hidden' --bind='ctrl-v:toggle-preview')
#   eval builtin cd ${dir:-.}
#
#   __path_prompt__
#   zle reset-prompt
# }
# zle -N __fzf_cd_widget__
# bindkey '\ec' __fzf_cd_widget__
