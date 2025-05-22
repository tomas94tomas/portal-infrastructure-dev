#!/usr/bin/env bash

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
EXTERNAL_BIN_PATH="$(realpath "$SCRIPT_PATH/../external")"
PATH=$PATH:${EXTERNAL_BIN_PATH}

exec-az.sh account show > /dev/null 2>&1
EXIT_CODE=$?
if [ "$EXIT_CODE" -ne 0 ]; then
    echo "Azure not logged in. Logging in..."
    exec-az.sh login
else
    echo "Azure already logged in."
fi
