#!/usr/bin/env bash

get_script_path() {
  local dir_path

  dir_path=$( dirname "${BASH_SOURCE[0]}" )

  cd "$dir_path" && pwd
}

login_to_all_registries() {
  local script_path="$1"

  "$script_path/../docker/login-to-all-registries.sh"
}

load_env_vars() {
  local script_path="$1"

  . "$script_path/../config/load-all-env.sh" > /dev/null 2>&1
}

install_dependencies() {
  local script_path="$1"

  "${script_path}"/install-helmfile.sh > /dev/null 2>&1
  "${script_path}"/install-vals.sh > /dev/null 2>&1
  "${script_path}"/install-sops.sh > /dev/null 2>&1
  "${script_path}"/install-aws.sh > /dev/null 2>&1
}

main() {
  local script_path

  script_path="$(get_script_path)"

  load_env_vars "$script_path"
  login_to_all_registries "$script_path"
  install_dependencies "$script_path"

  # shellcheck disable=SC2164
  cd "$script_path/../../";

  realpath "$(pwd)"

  PATH=$PATH:${script_path}

  "${script_path}"/../terraform/use-tf-aws-env-data.sh \
    env \
    HELM_SECRETS_BACKEND=vals \
    helmfile "$@"
}

main "$@"
