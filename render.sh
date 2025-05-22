#!/usr/bin/env bash

# Renders all templates from helmfile

SCRIPT_PATH="$(cd "$(dirname "$0")" && pwd)"

EXEC_MODE=render "${SCRIPT_PATH}"/update.sh "$@"
