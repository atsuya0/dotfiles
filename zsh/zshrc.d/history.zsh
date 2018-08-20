# コマンドの終了ステータスを見てファイルに記録するか否かを決めたいので、
# ここではファイルには記録しない。
# 0 記録する, 1 記録しない, 2 メモリにだけ記録する
function _record_cmd() {
  typeset -g _cmd=${1%%$'\n'}
  return 2
}
add-zsh-hook zshaddhistory _record_cmd

function _save_cmd() {
  local exit_status="$?"
  #_cmd=$(echo ${_cmd} | tr -s ' ') # 連続する空白を1つにする; sed /  */ で連続する空白を使う
  [[ ! ${_cmd} =~ ' ' ]] && return # 引数やオプションを指定していない場合は記録しない
  [[ ${_cmd} =~ '^ ' ]] && return

  # 履歴に記録しないコマンドを記述
  local ignore_cmds=(\
    cds up trash md gcm gco gaf ll \
    ls cd mv cp rm mkdir rmdir touch man less history source '\.' export type which file stat \
    vi vim sudoedit command builtin chromium unzip tree test '\[' '\[\[' \
    nvim code python go \
  )

  local ignore_cmd
  for ignore_cmd in ${ignore_cmds}; do
    [[ ${_cmd} =~ "^${ignore_cmd}" ]] && return
  done
  # コマンドが正常終了した場合はファイルに記録する
  [[ ${exit_status} == 0 ]] && print -sr -- "${_cmd}"
}
add-zsh-hook precmd _save_cmd
