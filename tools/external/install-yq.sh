#!/usr/bin/env bash

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PATH=$PATH:${SCRIPT_PATH}

# Check if yq is installed
if ! command -v yq &> /dev/null
then
    echo "yq is not installed. Installing..."
    "$SCRIPT_PATH"/download-latest-from-github.sh "mikefarah/yq" yq_linux_amd64
    rm -rf "$SCRIPT_PATH/yq" || true
    mv "$SCRIPT_PATH/yq_linux_amd64" "$SCRIPT_PATH/yq"
    chmod +x "$SCRIPT_PATH/yq"
    echo "yq has been installed to $SCRIPT_PATH/yq."
else
    echo "yq is already installed."
fi