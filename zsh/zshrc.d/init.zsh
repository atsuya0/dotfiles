[[ -e ${_CD_FILE} ]] || export _CD_FILE=$(mktemp)

# installed tmux && installed fzf && sessionが存在しない && GUI && True Color対応の仮想端末であるmlterm => tmux起動
type tmux > /dev/null 2>&1 && type fzf > /dev/null 2>&1 \
&& [[ -z ${TMUX} \
      && -n ${WINDOWID} \
      && $(ps -ho args ${PPID} | tr -s ' ' | cut -d' ' -f1) =~ 'mlterm|alacritty' \
]] && () {
  local new='new-session'
  id=$(
    echo "$(tmux list-sessions 2> /dev/null)\n${new}:" \
    | sed /^$/d | fzf --select-1 --reverse | cut -d: -f1
  )

  if [[ ${id} = ${new} ]]; then
    tmux -f "${HOME}/dotfiles/tmux/tmux.conf" -2 new-session && exit
  elif [[ -n ${id} ]]; then
    tmux attach-session -t ${id}
  fi
} && return
