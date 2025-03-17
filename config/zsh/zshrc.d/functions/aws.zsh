function tfcd() {
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
