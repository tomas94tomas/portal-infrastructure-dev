#!/usr/bin/env bash

# Get latest logs for latest pod by name

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

POD_NAME="$1"
if [[ -z "$POD_NAME" ]]; then
  echo "Error: POD_NAME as argument not set"
  exit 2
fi

POD_NAMESPACE="$2"
if [[ -z "$POD_NAMESPACE" ]]; then
  POD_NAMESPACE=default
fi;

# shellcheck disable=SC2164
pushd "$SCRIPT_PATH" > /dev/null

  # shellcheck disable=SC2046
  ./kubectl.sh logs -n "$POD_NAMESPACE" -f --tail=100 $(kubectl get pods -n "$POD_NAMESPACE" | grep "$POD_NAME" | cut -d' ' -f1 | head -n 1)

# shellcheck disable=SC2164
popd > /dev/null
