function set_aws_profile() {
  local -r profile=$(command aws configure list-profiles | fzf)
  [[ -z ${profile} ]] && return
  export AWS_PROFILE=${profile}
}

function aws() {
  [[ -z ${AWS_PROFILE} ]] && set_aws_profile
  echo "AWS_PROFILE=${AWS_PROFILE}"
  command aws $@
}
