#!/usr/bin/env bash

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PATH=$PATH:${SCRIPT_PATH}

# Check if terraform is installed
if ! command -v terraform &> /dev/null
then
    echo "terraform is not installed. Installing..."
    LATEST_RELEASE=$("$SCRIPT_PATH"/get-latest-github-release-version.sh "hashicorp/terraform")
    TAG_WITHOUT_V=${LATEST_RELEASE#v}
    TEMP_DIR=$(mktemp -d)
    rm -rf "$SCRIPT_PATH/terraform" || true
    wget -O "$TEMP_DIR/terraform_linux_amd64.zip" "https://releases.hashicorp.com/terraform/${TAG_WITHOUT_V}/terraform_${TAG_WITHOUT_V}_linux_amd64.zip"
    unzip "$TEMP_DIR/terraform_linux_amd64.zip" -d "$TEMP_DIR/latest"
    mv "$TEMP_DIR/latest/terraform" "$SCRIPT_PATH/terraform"
    chmod +x "$SCRIPT_PATH/terraform"
    rm -rf "$TEMP_DIR" || true
    echo "terraform has been installed to $SCRIPT_PATH/terraform."
else
    echo "terraform is already installed."
fi
