#!/usr/bin/env bash

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PATH=$PATH:${SCRIPT_PATH}

# Check if helm is installed
if ! command -v helm &> /dev/null
then
    echo "helm is not installed. Installing..."
    LATEST_RELEASE=$("$SCRIPT_PATH"/get-latest-github-release-version.sh "helm/helm")
    rm -rf "$SCRIPT_PATH/helm.tar.gz" || true
    curl -o "$SCRIPT_PATH/helm.tar.gz" "https://get.helm.sh/helm-${LATEST_RELEASE}-linux-amd64.tar.gz"
    mkdir -p "$SCRIPT_PATH/extracted"
    tar -xzvf "$SCRIPT_PATH/helm.tar.gz" -C "$SCRIPT_PATH/extracted"
    cp "$SCRIPT_PATH/extracted/linux-amd64/helm" "$SCRIPT_PATH/helm"
    chmod +x "$SCRIPT_PATH/helm"
    rm -rf "$SCRIPT_PATH/helm.tar.gz" "$SCRIPT_PATH/extracted"
    echo "helm has been installed to $SCRIPT_PATH/helm."
else
    echo "helm is already installed."
fi
