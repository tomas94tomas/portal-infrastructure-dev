#!/usr/bin/env bash

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PATH=$PATH:${SCRIPT_PATH}

# Check if yq is installed
if ! command -v sops &> /dev/null
then
    echo "sops is not installed. Installing..."
    LATEST_RELEASE=$("$SCRIPT_PATH"/get-latest-github-release-version.sh "getsops/sops")
    "$SCRIPT_PATH"/download-latest-from-github.sh "getsops/sops" "sops-${LATEST_RELEASE}.linux.amd64"
    chmod +x "$SCRIPT_PATH/sops-${LATEST_RELEASE}.linux.amd64"
    mv "$SCRIPT_PATH/sops-${LATEST_RELEASE}.linux.amd64" "$SCRIPT_PATH/sops"
    echo "sops has been installed to $SCRIPT_PATH/sops."
else
    echo "sops is already installed."
fi
