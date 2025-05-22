#!/usr/bin/env bash

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
EXTERNAL_BIN_PATH="$(realpath "$SCRIPT_PATH/../external")"
PATH=$PATH:${EXTERNAL_BIN_PATH}

install_dependencies() {
 install-yq.sh > /dev/null 2>&1
 install-jq.sh > /dev/null 2>&1
}

load_env_file() {
  . "$SCRIPT_PATH/../config/load-main-env.sh"
}

get_helmfile_var() {
  local environment="$1"
  local var_path="$2"

  "$SCRIPT_PATH/../helmfile/get-var.sh" "$environment" "$var_path"
}

yaml_to_json() {
  local content="$1"

  echo "$content" | yq -o=json
}

get_all_docker_registries() {
  local PROD_REGISTRIES_YAML;
  local DEV_REGISTRIES_YAML;
  local PROD_REGISTRIES_JSON;
  local DEV_REGISTRIES_JSON;

  PROD_REGISTRIES_YAML=$(get_helmfile_var production 'container.registries')
  DEV_REGISTRIES_YAML=$(get_helmfile_var development 'container.registries')

  PROD_REGISTRIES_JSON=$(yaml_to_json "$PROD_REGISTRIES_YAML")
  DEV_REGISTRIES_JSON=$(yaml_to_json "$DEV_REGISTRIES_YAML")

  jq --slurp 'add' <(echo "$PROD_REGISTRIES_JSON") <(echo "$DEV_REGISTRIES_JSON")
}

get_json_object_keys() {
  local json="$1"

  echo "$json" | jq -r 'keys[]'
}

get_json_object_subkey_value() {
  local json_data="$1"
  local base_key="$2"
  local sub_key="$3"

  echo "$json_data" | jq -r ".${base_key}.${sub_key}"
}

get_registry_server_from_json() {
  local json="$1"
  local registry_name="$2"

  get_json_object_subkey_value "$json" "$registry_name" server
}

get_registry_password_from_json() {
  local json="$1"
  local registry_name="$2"
  local env_var_name

  env_var_name=$(get_json_object_subkey_value "$json" "$registry_name" password_from_env)

  echo "${!env_var_name}"
}

get_registry_username_from_json() {
  local json="$1"
  local registry_name="$2"
  local env_var_name

  env_var_name=$(get_json_object_subkey_value "$json" "$registry_name" username_from_env)

  echo "${!env_var_name}"
}

docker_login() {
  local registry_username="$1"
  local registry_password="$2"
  local registry_server="$3"

  echo "$registry_password" | docker login "$registry_server" -u "$registry_username" --password-stdin
}

auth_with_docker_registry() {
  local json="$1"
  local registry_name="$2"
  local registry_username
  local registry_password
  local registry_server

  registry_username=$(get_registry_username_from_json "$json" "$registry_name")
  registry_password=$(get_registry_password_from_json "$json" "$registry_name")
  registry_server=$(get_registry_server_from_json "$json" "$registry_name")

  if docker_login "$registry_username" "$registry_password" "$registry_server" > /dev/null 2>&1; then
    return 0
  fi

  return 1
}

do_login() {
  local all_registries_json;
  local registry_name;

  all_registries_json=$(get_all_docker_registries)

  for registry_name in $(get_json_object_keys "$all_registries_json"); do
    echo -n "Logging into $registry_name..."

    if auth_with_docker_registry "$all_registries_json" "$registry_name"; then
      echo -e "  \033[0;32mSuccess!\033[0m"
    else
      echo -e "  \033[0;31mError\033[0m"
    fi
  done;
}

load_env_file
install_dependencies
do_login
