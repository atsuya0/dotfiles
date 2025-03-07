function set_aws_profile() {
  local -r profile=$(aws configure list-profiles | fzf)
  [[ -z ${profile} ]] && return 2
  export AWS_PROFILE=${profile}
}

function paws() {
  [[ -z ${AWS_PROFILE} ]] && set_aws_profile
  echo "AWS_PROFILE=${AWS_PROFILE}"
  aws $@
}

function tfcd() {
  [[ -z ${AWS_PROFILE} ]] && { set_aws_profile || return }

  local -r wd=$(basename ${PWD})

  case $1 in
    'init' )
      terraform -chdir=.. init -backend-config=${wd}/backend.tfvars --reconfigure $argv[2,-1]
    ;;
    'plan'|'apply'|'import'|'console'|'destroy'|'refresh' )
      terraform -chdir=.. $1 -var-file=${wd}/terraform.tfvars $argv[2,-1]
    ;;
    'output'|'state'|'graph' )
      terraform -chdir=.. $@
    ;;
    * )
      echo 'unkown command'
    ;;
  esac
}
