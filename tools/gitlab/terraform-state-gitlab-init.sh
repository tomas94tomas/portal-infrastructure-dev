#!/usr/bin/env bash

environment_exists() {
  local environment="$1"

  assert-environment-exists.sh "$environment" > /dev/null 2>&1
}

get_all_possible_environments() {
  get-all-environments.sh
}

terraform_init() {
  local gitlab_project_id="$1"
  local terraform_state_name="$2"
  local gitlab_username="$3"
  local gitlab_password="$4"
  local terraform_path="$5"

  terraform \
      -chdir="$terraform_path" \
      init \
      -reconfigure \
      -backend-config="address=https://gitlab.com/api/v4/projects/${gitlab_project_id}/terraform/state/${terraform_state_name}" \
      -backend-config="lock_address=https://gitlab.com/api/v4/projects/${gitlab_project_id}/terraform/state/${terraform_state_name}/lock" \
      -backend-config="unlock_address=https://gitlab.com/api/v4/projects/${gitlab_project_id}/terraform/state/${terraform_state_name}/lock" \
      -backend-config="username=${gitlab_username}" \
      -backend-config="password=${gitlab_password}" \
      -backend-config="lock_method=POST" \
      -backend-config="unlock_method=DELETE" \
      -backend-config="retry_wait_min=5"
}

install_dependencies() {
  install-teraform.sh > /dev/null 2>&1
}

get_terraform_version() {
  terraform --version | head -n 1 | cut -d' ' -f2-
}

set -e

ENVIRONMENT="$1"
SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
EXTERNAL_PATH="$(realpath "${SCRIPT_PATH}/../external")"
HELMFILE_PATH="$(realpath "${SCRIPT_PATH}/../helmfile")"
CONFIG_PATH="$(realpath "${SCRIPT_PATH}/../config")"
PATH=${PATH}:${SCRIPT_PATH}:${EXTERNAL_PATH}:${HELMFILE_PATH}:${CONFIG_PATH}

TERRAFORM_PROJECT_PATH=$(realpath "${SCRIPT_PATH}/../../terraform")

if [[ -z "$ENVIRONMENT" ]]; then
  echo "Syntax: $0 ENVIRONMENT"
  exit 2
fi;

if ! environment_exists "$ENVIRONMENT"; then
  echo "Error: Environment $ENVIRONMENT does not exists"
  echo "Possible values: $(get_all_possible_environments)"
  exit 3
fi;

install_dependencies
. "load-all-env.sh" &> /dev/null

echo "Terraform project path: $TERRAFORM_PROJECT_PATH"
echo "Terraform version: $(get_terraform_version)"

terraform_init \
  "$GITLAB_PROJECT_SECRET_ID" \
  "$ENVIRONMENT" \
  "$GITLAB_PROJECT_SECRET_USER" \
  "$GITLAB_PROJECT_SECRET_API_TOKEN" \
  "$TERRAFORM_PROJECT_PATH"
