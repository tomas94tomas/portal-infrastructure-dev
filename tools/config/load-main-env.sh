#!/usr/bin/env bash

get_script_path() {
  local dir_path

  dir_path=$( dirname "${BASH_SOURCE[0]}" )

  cd "$dir_path" && pwd
}

get_env_file() {
  local script_path="$1"

  echo "$script_path/../../.env"
}

main() {
  local script_path="$1"
  local env_file

  env_file=$(get_env_file "$script_path")

  if [ -f "$env_file" ]; then
    echo "Loading main .env..."
    set -o allexport
    set -a
    source "$env_file"
    set +o allexport
  else
    echo "No local .env found. So no auto loading extra environment variables."
  fi;
}

main "$(get_script_path)"
