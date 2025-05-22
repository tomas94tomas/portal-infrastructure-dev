#!/usr/bin/env bash

ENVIRONMENT="$1"
if [[ -z "$ENVIRONMENT" ]]; then
  echo "Syntax: $0 ENVIRONMENT"
  exit 128
fi;

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PATH=${PATH}:${SCRIPT_PATH}

for POSSIBLE_ENVIRONMENT in $(get-all-environments.sh); do
  if [[ "$POSSIBLE_ENVIRONMENT" == "$ENVIRONMENT" ]]; then
    echo "Yes"
    exit 0
  fi;
done

echo "No"
exit 1;
