#!/usr/bin/env bash

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --subscription-id) AZURE_SUBSCRIPTION_ID="$2"; shift ;;
        --resource-group) AZURE_RESOURCE_GROUP="$2"; shift ;;
        --resource-type) AZURE_RESOURCE_TYPE="$2"; shift ;;
        --resource-name) AZURE_RESOURCE_NAME="$2"; shift ;;
        --client-id) AZURE_CLIENT_ID="$2"; shift ;;
        --role) ROLE="$2"; shift ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
    shift
done

if [[ -z $AZURE_SUBSCRIPTION_ID || -z $AZURE_RESOURCE_GROUP || -z $AZURE_RESOURCE_TYPE || -z $AZURE_RESOURCE_NAME || -z $AZURE_CLIENT_ID || -z $ROLE ]]; then
    echo "Usage: $0 --subscription-id AZURE_SUBSCRIPTION_ID --resource-group AZURE_RESOURCE_GROUP --resource-type AZURE_RESOURCE_TYPE --resource-name AZURE_RESOURCE_NAME --client-id AZURE_CLIENT_ID --role ROLE"
    exit 1
fi

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
EXTERNAL_BIN_PATH="$(realpath "$SCRIPT_PATH/../external")"
PATH=$PATH:${EXTERNAL_BIN_PATH}

## Uncomment lines below for debugging
#echo "Azure Subscription ID: $AZURE_SUBSCRIPTION_ID"
#echo "Azure Resource Group: $AZURE_RESOURCE_GROUP"
#echo "Azure Resource Type: $AZURE_RESOURCE_TYPE"
#echo "Azure Resource Name: $AZURE_RESOURCE_NAME"
#echo "Azure Client ID: $AZURE_CLIENT_ID"
#echo "Role: $ROLE"

SCOPE="/subscriptions/${AZURE_SUBSCRIPTION_ID}/resourceGroups/${AZURE_RESOURCE_GROUP}/providers/${AZURE_RESOURCE_TYPE}/${AZURE_RESOURCE_NAME}"

echo "Validating role assignment..."
ASSIGNMENT_CHECK=$(exec-az.sh role assignment list --assignee "$AZURE_CLIENT_ID" --role "$ROLE" --scope "$SCOPE" --query "[?roleDefinitionName=='$ROLE'].principalId" --output tsv)

if [ -z "$ASSIGNMENT_CHECK" ]; then
  echo "Not assigned yet. Assigning role."
  exec-az.sh role assignment create --role "$ROLE" --assignee "$AZURE_CLIENT_ID" --scope "$SCOPE"
else
  echo "Skipping assignment. Already have."
fi;
