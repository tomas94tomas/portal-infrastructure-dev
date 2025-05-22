#!/usr/bin/env bash

SCRIPT_PATH="$(cd "$(dirname "$0")" && pwd)"
PROJECT_PATH=$("$SCRIPT_PATH"/../terraform/get_terraform_project_path.sh)

echo "$PROJECT_PATH/tfplan"
