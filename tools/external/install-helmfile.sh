#!/usr/bin/env bash

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PATH=$PATH:${SCRIPT_PATH}

# Check if yq is installed
if ! command -v helmfile &> /dev/null
then
    echo "helmfile is not installed. Installing..."
    LATEST_RELEASE=$("$SCRIPT_PATH"/get-latest-github-release-version.sh "helmfile/helmfile")
    tag_without_v=${LATEST_RELEASE#v}
    "$SCRIPT_PATH"/download-latest-from-github.sh "helmfile/helmfile" "helmfile_${tag_without_v}_linux_amd64.tar.gz"
    rm -rf "$SCRIPT_PATH/helmfile" || true
    mv "$SCRIPT_PATH/helmfile_${tag_without_v}_linux_amd64.tar.gz" "$SCRIPT_PATH/helmfile.tar.gz"
    mkdir -p "$SCRIPT_PATH/extracted"
    tar -xzvf "$SCRIPT_PATH/helmfile.tar.gz" -C "$SCRIPT_PATH/extracted"
    cp "$SCRIPT_PATH/extracted/helmfile" "$SCRIPT_PATH/helmfile"
    chmod +x "$SCRIPT_PATH/helmfile"
    rm -rf "$SCRIPT_PATH/helmfile.tar.gz" "$SCRIPT_PATH/extracted"
    echo "helmfile has been installed to $SCRIPT_PATH/helmfile."
else
    echo "helmfile is already installed."
fi
