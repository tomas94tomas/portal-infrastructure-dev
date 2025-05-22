#!/usr/bin/env bash

environment_exists() {
  local environment="$1"

  "$SCRIPT_PATH"/assert-environment-exists.sh "$environment" > /dev/null 2>&1
}

get_all_possible_environments() {
  "$SCRIPT_PATH"/get-all-environments.sh
}

ENVIRONMENT="$1"
SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ -z "$ENVIRONMENT" ]]; then
  echo "Syntax: $0 ENVIRONMENT"
  exit 2
fi;

if ! environment_exists "$ENVIRONMENT"; then
  echo "Error: Environment $ENVIRONMENT does not exists"
  echo "Possible values: $(get_all_possible_environments)"
  exit 3
fi;
