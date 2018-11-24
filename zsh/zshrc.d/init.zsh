[[ -e ${_CD_FILE} ]] || export _CD_FILE=$(mktemp)

tmux list-session &> /dev/null || () {
  type trash &> /dev/null && trash auto-delete
}

() {
  [[ -n ${WINDOWID} ]] || return 1
  [[ $(ps -ho cmd ${PPID} | tr -s ' ' | cut -d' ' -f1) \
    == 'alacritty' ]] || return 1
  [[ -f ${DOTFILES}/tmux/management.sh ]] \
    && ${DOTFILES}/tmux/management.sh \
    && exit
}
