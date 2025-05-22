#!/usr/bin/env bash

# Run this script when something with helm or helmfile related changes
# Also if there are some env variables changes
# It should update current deployment

validate_environment() {
  local environment="$1"
  local exit_code

  "${SCRIPT_PATH}"/tools/helmfile/validate-environment.sh "$environment"
  exit_code=$?

  if [ $exit_code -ne 0 ]; then
    echo "Error: incorrect environment"
    exit $exit_code
  fi
}

init_terraform_gitlab_state() {
  local environment="$1"

  "${SCRIPT_PATH}"/tools/gitlab/terraform-state-gitlab-init.sh "$environment"
}

get_helmfile_value() {
  local environment="$1"
  local key_path="$2"

  "${SCRIPT_PATH}/tools/helmfile/get-var.sh" "$environment" "$key_path"
}

get_short_env_name() {
  local environment="$1"

  get_helmfile_value "$environment" "kubernetes.prefix"
}

exec_terraform() {
  "${SCRIPT_PATH}/tools/terraform/exec_terraform_action.sh" "$@"
}

get_terraform_project_plan_file() {
  "${SCRIPT_PATH}"/tools/terraform/get_terraform_project_plan_file.sh
}

terraform_plan() {
  local terraform_project_plan_file
  local env_name
  local environment="$1"

  terraform_project_plan_file=$(get_terraform_project_plan_file)
  env_name=$(get_short_env_name "$environment")

  exec_terraform \
    plan \
    -out="${terraform_project_plan_file}" \
    -var "environment=$env_name" \
    -lock=false
}

terraform_apply() {
  local terraform_project_plan_file

  terraform_project_plan_file=$(get_terraform_project_plan_file)

  exec_terraform \
     apply \
     -lock=false \
    "$terraform_project_plan_file"
}

delete_terraform_plan() {
  local terraform_project_plan_file;

  terraform_project_plan_file=$(get_terraform_project_plan_file)

  if [ -f "$terraform_project_plan_file" ]; then
    rm -rf "$terraform_project_plan_file"
  fi
}

get_terraform_value() {
  local key_path="$1"

  "${SCRIPT_PATH}"/tools/terraform/get_terraform_var.sh "$key_path"
}

get_aws_region() {
  get_terraform_value "cluster-region"
}

get_aws_cluster() {
  get_terraform_value "cluster-name"
}

do_exit_stuff() {
  delete_terraform_plan
}

login_to_kubernetes_cluster() {
  local region
  local cluster

  region=$(get_aws_region)
  cluster=$(get_aws_cluster)

  "${SCRIPT_PATH}"/tools/terraform/use-tf-aws-env-data.sh \
    "${SCRIPT_PATH}"/tools/aws/aws-update-kubeconfig.sh "$region" "$cluster"
}

load_all_env_vars() {
  . "$SCRIPT_PATH/tools/config/load-all-env.sh" &> /dev/null
}

helmfile_sync() {
  local environment="$1"
  # shellcheck disable=SC2124
  local filtered_params="${@:2}"

  "$SCRIPT_PATH/tools/external/exec-helmfile.sh" sync -e "$environment" "$filtered_params"
}

get_script_path() {
  local dir_path

  dir_path=$(dirname "$0")

  cd "$dir_path" && pwd
}

validate_exec_mode() {
  local mode="$1"

  case "$mode" in
    apply)
      return 0
      ;;
    render)
      return 0
    ;;
    *)
      echo "Error: bad EXEC_MODE. Only 'render' and 'apply' supported"
      exit 110
  esac
}

clear_old_rendered_files() {
  rm -rf ./rendered/* || true
}

render_helmfile() {
  local environment="$1"
  local other_params="${*:2}"

  "$SCRIPT_PATH/tools/external/exec-helmfile.sh" \
      write-values \
      --output-file-template "$SCRIPT_PATH/rendered/values/{{ .State.BaseName }}/{{ .Release.Name}}.yaml" \
      -e "$environment"

  "$SCRIPT_PATH/tools/external/exec-helmfile.sh" \
    template \
    --output-dir-template "{{ .OutputDir }}/{{ .Release.Name}}" \
    --output-dir "$SCRIPT_PATH/rendered/helm" \
    -e "$environment" \
    "$other_params"
}

move_terraform_plan_to_rendered() {
    local terraform_project_plan_file;
    local new_terraform_project_plan_file;

    terraform_project_plan_file=$(get_terraform_project_plan_file)

    if [ -f "$terraform_project_plan_file" ]; then
      new_terraform_project_plan_file=$(basename "$terraform_project_plan_file")
      new_terraform_project_plan_file=$(realpath "$SCRIPT_PATH/rendered/$new_terraform_project_plan_file")
      echo "Terraform plan is available on $new_terraform_project_plan_file"
      mv "$terraform_project_plan_file" "$new_terraform_project_plan_file"
    fi
}

main() {
  local environment="$1"
  local exec_mode=apply

  if [[ -n "$EXEC_MODE" ]]; then
    exec_mode="$EXEC_MODE"
  fi;

  validate_environment "$environment"
  validate_exec_mode "$exec_mode"

  load_all_env_vars
  init_terraform_gitlab_state "$environment"
  terraform_plan "$environment"

  case "$exec_mode" in
   apply)
     terraform_apply
     login_to_kubernetes_cluster
     helmfile_sync "$@"
   ;;
   render)
     clear_old_rendered_files
     render_helmfile "$@"
     move_terraform_plan_to_rendered
   ;;
  esac
}

SCRIPT_PATH="$(get_script_path)"

trap do_exit_stuff EXIT

set -e
main "$@"
