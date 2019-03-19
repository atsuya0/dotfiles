[[ -n $TMUX ]] && return

# ログイン後にディスプレイマネージャを使わずにXを起動。
# [[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx
