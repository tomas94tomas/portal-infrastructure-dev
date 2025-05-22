#!/usr/bin/env bash

PLAN_PATH=$1
PLAN_JSON_PATH="$2"
if [[ -z "$PLAN_PATH" ]] || [[ -z "$PLAN_JSON_PATH" ]]; then
  echo "Syntax: $0 TERRAFORM_PLAN_PATH PLAN_JSON_PATH"
  exit 1
fi;

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
EXTERNAL_PATH="$(realpath "${SCRIPT_PATH}/../external")"
TERRAFORM_PATH="$(realpath "${SCRIPT_PATH}/../terraform")"
PATH=${PATH}:${SCRIPT_PATH}:${EXTERNAL_PATH}:${TERRAFORM_PATH}

TERRAFORM_PLAN_PATH=$(get_terraform_project_path.sh)

alias convert_report="jq -r '([.resource_changes[]?.change.actions?]|flatten)|{\"create\":(map(select(.==\"create\"))|length),\"update\":(map(select(.==\"update\"))|length),\"delete\":(map(select(.==\"delete\"))|length)}'"
shopt -s expand_aliases

install-jq.sh  > /dev/null 2>&1
install-terraform.sh  > /dev/null 2>&1

PLAN_PATH=$(realpath "$PLAN_PATH")

terraform -chdir="${TERRAFORM_PLAN_PATH}" show --json "$PLAN_PATH" | convert_report > "$PLAN_JSON_PATH"
