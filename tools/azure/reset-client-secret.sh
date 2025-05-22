#!/usr/bin/env bash

AZURE_CLIENT_ID="$1"

if [[ -z $AZURE_CLIENT_ID ]]; then
    echo "Usage: $0 AZURE_CLIENT_ID"
    exit 1
fi

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
EXTERNAL_BIN_PATH="$(realpath "$SCRIPT_PATH/../external")"
PATH=$PATH:${EXTERNAL_BIN_PATH}

install-jq.sh > /dev/null 2>&1

echo "Resetting client secret..."
RESET_PASS_RESPONSE=$(exec-az.sh ad app credential reset --id "$AZURE_CLIENT_ID" --display-name "kubernetes" --only-show-errors)

echo "New password (client secret):"
echo "$RESET_PASS_RESPONSE" | jq -r '.password'
