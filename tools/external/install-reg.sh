#!/usr/bin/env bash

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PATH=$PATH:${SCRIPT_PATH}

# Check if reg is installed
if ! command -v reg &> /dev/null
then
    echo "reg is not installed. Installing..."
    "$SCRIPT_PATH"/download-latest-from-github.sh "genuinetools/reg" "reg-linux-amd64"
    mv "$SCRIPT_PATH/reg-linux-amd64" "$SCRIPT_PATH/reg"
    chmod +x "$SCRIPT_PATH/reg"
    echo "reg has been installed to $SCRIPT_PATH/reg."
else
    echo "reg is already installed."
fi
