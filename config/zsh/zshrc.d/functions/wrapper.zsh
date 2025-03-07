function vim() { # Choose files to open by fzf.
  function editor() {
    if [[ -n ${commands[nvim]} ]]; then
      echo "nvim $@"
    elif [[ -n ${commands[vim]} ]]; then
      echo "vim $@"
    else
      echo "vi $@"
    fi
  }

  function choice() {
    [[ -z ${commands[fzf]} ]] && return 1
    eval find ${1:-.} \
      $(ignore_filetypes) $(ignore_dirs) $(ignore_absolute_paths) \
      -type f -print \
      | fzf --select-1 --preview='less {}' \
        --preview-window='right:hidden' --bind='ctrl-v:toggle-preview'
  }

  [[ $# -ne 0 && ! -d $1 ]] && { eval $(editor $@); return 0; }

  local -r files=$(choice $1)
  [[ -n ${files} ]] && eval $(editor ${files})
}
