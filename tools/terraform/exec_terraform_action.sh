#!/usr/bin/env bash

get_terraform_project_path() {
  "${SCRIPT_PATH}"/get_terraform_project_path.sh
}

get_terraform_project_plan_file() {
  "${SCRIPT_PATH}"/get_terraform_project_plan_file.sh
}

exec_terraform() {
  local terraform_project_path

  terraform_project_path=$(get_terraform_project_path)

 "${SCRIPT_PATH}"/use-tf-aws-env-data.sh \
    "${SCRIPT_PATH}"/../external/terraform \
      -chdir="${terraform_project_path}" \
      "$@"
}

install_terraform_if_needed() {
  "${SCRIPT_PATH}"/../external/install-teraform.sh  > /dev/null 2>&1
}

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

install_terraform_if_needed
exec_terraform "$@"
