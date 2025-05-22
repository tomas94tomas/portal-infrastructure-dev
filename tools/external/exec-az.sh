#!/usr/bin/env bash

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PATH=$PATH:${SCRIPT_PATH}

# Check if az is installed
if ! command -v az &> /dev/null; then
    docker run -v ~/.ssh:/root/.ssh -it mcr.microsoft.com/azure-cli:latest /usr/local/bin/az "$@"
else
    az "$@"
fi
