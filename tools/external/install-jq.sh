#!/usr/bin/env bash

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PATH=$PATH:${SCRIPT_PATH}

# Check if jq is installed
if ! command -v jq &> /dev/null
then
    echo "jq is not installed. Installing..."
    "$SCRIPT_PATH"/download-latest-from-github.sh "jqlang/jq" "jq-linux-amd64"
    mv "$SCRIPT_PATH/jq-linux-amd64" "$SCRIPT_PATH/jq"
    chmod +x "$SCRIPT_PATH/jq"
    echo "jq has been installed to $SCRIPT_PATH/jq."
else
    echo "jq is already installed."
fi
