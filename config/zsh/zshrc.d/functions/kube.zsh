function kubec() {
  [[ -z ${commands[yq]} ]] && return 1
  [[ -z ${commands[fzf]} ]] && return 1
  [[ -z ${commands[kubectl]} ]] && return 1

  local -r name=$(kubectl config get-contexts -o=name \
    | grep -v "^$(kubectl config current-context)$" \
    | fzf)
  [[ -n ${name} ]] \
    && kubectl config use-context ${name} \
    && export KUBE_CONTEXT="${name}#$(kubectl config view --minify | yq '.contexts[0].context | .namespace')"
}

function kuben() {
  [[ -z ${commands[yq]} ]] && return 1
  [[ -z ${commands[fzf]} ]] && return 1
  [[ -z ${commands[kubectl]} ]] && return 1

  typeset -a kube_context=($(kubectl config view --minify | yq '.contexts[0].context | .cluster + " " + .namespace'))
  local -r name=$(kubectl get namespace -o=name | cut -d/ -f2 \
    | grep -v "^${kube_context[2]}$" \
    | fzf)
  [[ -n ${name} ]] \
    && kubectl config set-context --current --namespace=${name} \
    && export KUBE_CONTEXT="${kube_context[1]}#${name}"
}

function kubes() {
  [[ -z ${commands[yq]} ]] && return 1
  [[ -z ${commands[kubectl]} ]] && return 1

  case $1 in
    '-s' )
      export KUBE_CONTEXT=
    ;;
    * )
      export KUBE_CONTEXT=$(kubectl config view --minify | yq '.contexts[0].context | .cluster + "#" + .namespace')
    ;;
  esac
}
