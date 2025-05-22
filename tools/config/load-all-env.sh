#!/usr/bin/env bash

get_script_path() {
  local script_path;
  script_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

  echo "$script_path"
}

load_main_env() {
  local script_path="$1"

  . "${script_path}/load-main-env.sh"
}

load_extra_env() {
  local script_path="$1"

  . "${script_path}/load-extra-env.sh"
}

env_file_exists() {
  local script_path="$1"
  local env_file_name="$2"
  local env_file_path;

  env_file_path=$(realpath "${script_path}/../../${env_file_name}")

  [ -f "$env_file_path" ]
}

write_gitlab_secrets_to_env() {
  local script_path="$1"

  "${script_path}/../gitlab/write-project-secrets-to-env-file.sh"
}

try_to_load_all_env() {
  local script_path;

  script_path=$(get_script_path)

  load_main_env "$script_path"
  if ! env_file_exists "$script_path" ".env.gitlab"; then
    write_gitlab_secrets_to_env "$script_path"
  fi
  load_extra_env "$script_path"
}

try_to_load_all_env

