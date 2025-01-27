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

  #local -r log_dir="${HOME}/.terraform.d/log/$(date +'%Y-%m-%d')/$(date +'%H')"
  #mkdir ${log_dir}
  #local -r log_file="$(expr 1 + $(ls -1 ${log_dir} | wc -l))"
  #export TF_LOG_PATH="${log_dir}/${log_file}.log"
  #echo ${TF_LOG_PATH}

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
