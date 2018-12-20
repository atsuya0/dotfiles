# 環境が汚染される。% echo ${__node_cmds__} ${__node_cmd__}

function __init_nvm__() { # nvm(Node.jsのversion管理)の初期設定を読み込む
  unset -f $@
  typeset -r nvm_path='/usr/share/nvm'
  [[ -e "${nvm_path}/nvm.sh" ]] && source "${nvm_path}/nvm.sh"
}

typeset -gar __node_cmds__=(
  'nvm'
  'node'
  'npm'
  'ng'
  'vue'
  'create-react-app'
  'firebase'
)

for __node_cmd__ in ${__node_cmds__[@]}; do
  function ${__node_cmd__} {
    __init_nvm__ ${__node_cmds__[@]}
    $0 $@
  }
done
