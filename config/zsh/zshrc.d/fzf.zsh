# <C-y>で文字列をコピー
export FZF_DEFAULT_OPTS="-m --height=80% --reverse --exit-0 --bind 'ctrl-y:execute-silent(echo {} | cut -f2- | pbcopy)+abort'"
# <C-v>で見切れたコマンドを表示
export FZF_CTRL_R_OPTS="--preview='echo {}' --preview-window=down:3:hidden:wrap --bind 'ctrl-v:toggle-preview'"
