typeset -r node_funcs=(
  'nvm'
  'node'
  'npm'
  'ng'
  'create-react-app'
)

function init_nvm() { # nvm(Node.jsのversion管理)の初期設定を読み込む
  unset -f ${node_funcs}
  local nvm_dir='/usr/share/nvm'
  [[ -e "${nvm_dir}/nvm.sh" ]] && source "${nvm_dir}/nvm.sh"
  [[ -e "${nvm_dir}/bash_completion" ]] && source "${nvm_dir}/bash_completion"
}

for func in ${node_funcs}; do
  function ${func} {
    init_nvm
    $0 $@
  }
done
