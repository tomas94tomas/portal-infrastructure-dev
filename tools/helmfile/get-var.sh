#!/usr/bin/env bash

ENVIRONMENT="$1"
VARIABLE="$2"

if [ -z "$ENVIRONMENT" ] || [ -z "$VARIABLE" ]; then
  echo "Usage: $0 ENVIRONMENT VARIABLE"
  exit 1
fi;

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
EXTERNAL_BIN_PATH="$(realpath "$SCRIPT_PATH/../external")"
HELMFILE_ROOT_PATH="$(realpath "$SCRIPT_PATH/../../helmfile.d/")"
HELMFILE_PATH="$(realpath "$HELMFILE_ROOT_PATH/helmfile.yaml")"
PATH=$PATH:${EXTERNAL_BIN_PATH}

install-yq.sh > /dev/null 2>&1

VALUES_FILES=$(cat "$HELMFILE_PATH" | yq eval ".environments | select(length > 0) | .$ENVIRONMENT.values | join(\" \")")
prefixed_paths=""
for path in $VALUES_FILES; do
    prefixed_paths+=" $(realpath "$HELMFILE_ROOT_PATH/$path")"
done
VALUES_FILES="$prefixed_paths"

# shellcheck disable=SC2086
MERGED_VALUES_YAML=$(yq eval-all 'select(fileIndex == 0) * select(fileIndex > 0)' $VALUES_FILES)

echo "$MERGED_VALUES_YAML" | yq eval ".$VARIABLE"
