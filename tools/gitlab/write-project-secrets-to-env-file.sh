#!/usr/bin/env bash

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo -n "Fetching & writing .env.gitlab..."
if "$SCRIPT_PATH/fetch-project-secrets-to-env-file.sh" > "$SCRIPT_PATH/../../.env.gitlab"; then
  echo -e "  \033[0;32mSuccess!\033[0m"
else
  ERROR=$(cat "$SCRIPT_PATH/../../.env.gitlab")
  echo -e "  \033[0;31m${ERROR}\033[0m"
  rm -rf "$SCRIPT_PATH/../../.env.gitlab" || true
fi;
