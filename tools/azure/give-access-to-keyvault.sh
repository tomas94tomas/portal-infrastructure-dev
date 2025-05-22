#!/usr/bin/env bash

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --subscription-id) AZURE_SUBSCRIPTION_ID="$2"; shift ;;
        --resource-group) AZURE_RESOURCE_GROUP="$2"; shift ;;
        --key-vault) AZURE_RESOURCE_NAME="$2"; shift ;;
        --client-id) AZURE_CLIENT_ID="$2"; shift ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
    shift
done

if [[ -z "$AZURE_SUBSCRIPTION_ID" || -z "$AZURE_RESOURCE_GROUP" || -z "$AZURE_RESOURCE_NAME" || -z "$AZURE_CLIENT_ID" ]]; then
    echo "Usage: $0 --subscription-id AZURE_SUBSCRIPTION_ID --resource-group AZURE_RESOURCE_GROUP --key-vault KEY_VAULT_NAME --client-id AZURE_CLIENT_ID"
    exit 1
fi

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# shellcheck disable=SC2164
pushd "$SCRIPT_PATH" > /dev/null

  ./assign-role.sh \
    --role "Key Vault Secrets User" \
    --resource-type "Microsoft.KeyVault/vaults" \
    --subscription-id "$AZURE_SUBSCRIPTION_ID" \
    --resource-group "$AZURE_RESOURCE_GROUP" \
    --resource-name "$AZURE_RESOURCE_NAME" \
    --client-id "$AZURE_CLIENT_ID"

# shellcheck disable=SC2164
popd > /dev/null