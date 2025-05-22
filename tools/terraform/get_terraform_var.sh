#!/usr/bin/env bash

VAR="$1"
if [ -z "$VAR" ]; then
  echo "Syntax: $0 VAR"
  exit 1
fi

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

"$SCRIPT_PATH"/exec_terraform_action.sh output -raw "$VAR"
