#!/usr/bin/env bash

get_script_path() {
  local dir_path

  dir_path=$( dirname "${BASH_SOURCE[0]}" )

  cd "$dir_path" && pwd
}

get_target_path() {
  local script_path

  script_path=$(get_script_path)

  realpath "$script_path/../../"
}

for env_file in "$(get_target_path)"/.env.*; do
    if [[ "$(basename "$env_file")" == ".env.dist" ]]; then
      continue;
    fi;

    echo "Loading $env_file"
    set -o allexport
    set -a
    # shellcheck disable=SC1090
    source "$env_file"
    set +o allexport
done
