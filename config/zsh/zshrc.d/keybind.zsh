# プロンプトでviのキーバインドを使う。
bindkey -v
# 挿入モードをemacsにする
bindkey -M viins '^f'  forward-char
bindkey -M viins '^b'  backward-char
bindkey -M viins '^a'  beginning-of-line
bindkey -M viins '^e'  end-of-line
bindkey -M viins '^d'  delete-char-or-list
bindkey -M viins '^h'  backward-delete-char
bindkey -M viins '^w'  backward-kill-word
bindkey -M viins '^u'  backward-kill-line
bindkey -M viins '^k'  kill-line
bindkey -M viins '^y'  yank
bindkey -M viins '^n'  down-line-or-history
bindkey -M viins '^p'  up-line-or-history
# ALT: \e, ^[
bindkey -M viins '\ef' forward-word
bindkey -M viins '\eb' backward-word
bindkey -M viins '\ed' kill-word
bindkey -M viins '\e.' insert-last-word
