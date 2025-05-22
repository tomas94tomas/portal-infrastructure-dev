#!/usr/bin/env bash

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PATH=$PATH:${SCRIPT_PATH}

# Check if yq is installed
if ! command -v vals &> /dev/null
then
    echo "vals is not installed. Installing..."
    LATEST_RELEASE=$("$SCRIPT_PATH"/get-latest-github-release-version.sh "helmfile/vals")
    tag_without_v=${LATEST_RELEASE#v}
    "$SCRIPT_PATH"/download-latest-from-github.sh "helmfile/vals" "vals_${tag_without_v}_linux_amd64.tar.gz"
    rm -rf "$SCRIPT_PATH/vals" || true
    mv "$SCRIPT_PATH/vals_${tag_without_v}_linux_amd64.tar.gz" "$SCRIPT_PATH/vals.tar.gz"
    mkdir -p "$SCRIPT_PATH/extracted"
    tar -xzvf "$SCRIPT_PATH/vals.tar.gz" -C "$SCRIPT_PATH/extracted"
    cp "$SCRIPT_PATH/extracted/vals" "$SCRIPT_PATH/vals"
    chmod +x "$SCRIPT_PATH/vals"
    rm -rf "$SCRIPT_PATH/vals.tar.gz" "$SCRIPT_PATH/extracted"
    echo "vals has been installed to $SCRIPT_PATH/vals."
else
    echo "vals is already installed."
fi
