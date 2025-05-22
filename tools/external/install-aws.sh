#!/usr/bin/env bash

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PATH=$PATH:${SCRIPT_PATH}

# Check if aws is installed
if ! command -v aws &> /dev/null
then
    echo "aws is not installed. Installing..."
    rm -rf "$SCRIPT_PATH/aws-cli" || true
    rm -rf "$SCRIPT_PATH/aws" || true
    rm -rf "$SCRIPT_PATH/aws_completer" || true
    TEMP_DIR=$(mktemp -d)
    wget "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -O "$TEMP_DIR/awscliv2.zip"
    unzip "$TEMP_DIR/awscliv2.zip" -d "$TEMP_DIR/latest"
    "$TEMP_DIR/latest/aws/install" --install-dir "$SCRIPT_PATH/aws-cli" --bin-dir "$SCRIPT_PATH"
    rm -rf "$TEMP_DIR" || true
    echo "aws has been installed to $SCRIPT_PATH/aws."
else
    echo "aws is already installed."
fi
