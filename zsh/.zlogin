[[ -n $TMUX ]] && return

type trash &> /dev/null && trash auto-delete

# ログイン後にディスプレイマネージャを使わずに、X window managerを起動する。
# [[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx
