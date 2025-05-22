#!/usr/bin/env bash

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PATH=$PATH:${SCRIPT_PATH}

# Check if yq is installed
if ! command -v kubelogin &> /dev/null
then
    sudo az aks install-cli
else
    echo "kubelogin is already installed."
fi
