#!/usr/bin/env bash

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
EXTERNAL_BIN_PATH="$(realpath "$SCRIPT_PATH/../external")"
HELMFILE_PATH="$(realpath "$SCRIPT_PATH/../../helmfile.d/helmfile.yaml")"
PATH=$PATH:${EXTERNAL_BIN_PATH}

install-yq.sh > /dev/null 2>&1
install-helmfile > /dev/null 2>&1

yq eval '.environments | select(length > 0) | keys | join(" ")' < "$HELMFILE_PATH"
