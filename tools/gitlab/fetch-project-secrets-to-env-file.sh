#!/usr/bin/env bash

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
EXTERNAL_BIN_PATH="$(realpath "$SCRIPT_PATH/../external")"
CONFIG_BIN_PATH="$(realpath "$SCRIPT_PATH/../config")"
PATH=$PATH:${EXTERNAL_BIN_PATH}:${CONFIG_BIN_PATH}

. load-main-env.sh  > /dev/null 2>&1

if [[ -z "$GITLAB_PROJECT_SECRET_ACCESS_TOKEN" ]]; then
  echo "Error: GITLAB_PROJECT_SECRET_ACCESS_TOKEN not set"
  exit 2
fi;

if [[ -z "$GITLAB_PROJECT_SECRET_ID" ]]; then
  echo "Error: GITLAB_PROJECT_SECRET_ID not set"
  exit 3
fi;

fetch_page() {
  local page="$1"

  curl --silent --header "PRIVATE-TOKEN: $GITLAB_PROJECT_SECRET_ACCESS_TOKEN" \
                  "https://gitlab.com/api/v4/projects/$GITLAB_PROJECT_SECRET_ID/variables?page=${page}"
}

parse_gitlab_vars_json_to_bash() {
  local json="$1"

  echo "$json" | jq -r -e '.[] | .key + "=" + (.value | tostring | @sh)'
}

fetch_all() {
  local page=1
  local response

  while true; do
    response=$(fetch_page "$page")
    if [[ "$response" == "[]" ]]; then
      break;
    fi;

    parse_gitlab_vars_json_to_bash "$response"

    ((page++))
  done;
}

install-jq.sh  > /dev/null 2>&1
fetch_all

