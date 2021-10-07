function kubec() {
  [[ -z ${commands[fzf]} ]] && return 1
  [[ -z ${commands[kubectl]} ]] && return 1

  local -r name=$(kubectl config get-contexts -o=name \
    | sed "/^$(kubectl config current-context)$/d" \
    | fzf)
  [[ -n ${name} ]] && kubectl config use-context ${name}
}


function kuben() {
  [[ -z ${commands[fzf]} ]] && return 1
  [[ -z ${commands[kubectl]} ]] && return 1

  local -r name=$(kubectl get namespace -o=name | cut -d/ -f2 \
    | sed "/^$(kubectl config get-contexts | grep '^*' | tr -s ' ' | cut -d' ' -f 5)$/d" \
    | fzf)
  [[ -n ${name} ]] && kubectl config set-context --current --namespace=${name}
}
