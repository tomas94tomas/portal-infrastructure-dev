#!/usr/bin/env bash

# This get user id for accessing secrets from kubernetes service

RESOURCE_GROUP_NAME="$1"
KUBERNETES_SERVICE_NAME="$2"

if [[ -z $RESOURCE_GROUP_NAME ]] || [[ -z $KUBERNETES_SERVICE_NAME ]]; then
    echo "Usage: $0 RESOURCE_GROUP_NAME KUBERNETES_SERVICE_NAME"
    exit 1
fi

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
EXTERNAL_BIN_PATH="$(realpath "$SCRIPT_PATH/../external")"
PATH=$PATH:${EXTERNAL_BIN_PATH}

# addonProfiles.azureKeyvaultSecretsProvider.identity.clientId
exec-az.sh aks show -g "$RESOURCE_GROUP_NAME" -n "$KUBERNETES_SERVICE_NAME" --query addonProfiles.azureKeyvaultSecretsProvider.identity.clientId -o tsv
