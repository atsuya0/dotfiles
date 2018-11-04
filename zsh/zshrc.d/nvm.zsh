typeset -gr node_funcs=(
  'nvm'
  'node'
  'npm'
  'ng'
  'vue'
  'create-react-app'
  'firebase'
)

function __init_nvm__() { # nvm(Node.jsのversion管理)の初期設定を読み込む
  unset -f $@
  local nvm_dir='/usr/share/nvm'
  [[ -e "${nvm_dir}/nvm.sh" ]] && source "${nvm_dir}/nvm.sh"
}

for func in ${node_funcs}; do
  function ${func} {
    __init_nvm__ ${node_funcs}
    $0 $@
  }
done
