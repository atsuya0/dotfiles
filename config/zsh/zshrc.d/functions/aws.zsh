function set_aws_profile() {
  local -r profile=$(aws configure list-profiles | fzf)
  [[ -z ${profile} ]] && return
  [[ -n $(aws configure get sso_account_id --profile ${profile}) ]] \
    && aws sso login --profile ${profile}
  export AWS_PROFILE=${profile}
}

function paws() {
  [[ -z ${AWS_PROFILE} ]] && set_aws_profile
  echo "AWS_PROFILE=${AWS_PROFILE}"
  aws $@
}
