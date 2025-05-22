#!/usr/bin/env bash

set -e

AWS_REGION="$1"
AWS_K8S_CLUSTER_NAME="$2"

if [ -z "$AWS_REGION" ] || [ -z "$AWS_K8S_CLUSTER_NAME" ]; then
  echo "Syntax: $0 AWS_REGION AWS_K8S_CLUSTER_NAME"
  exit 2
fi;

if [ -z "$AWS_ACCESS_KEY_ID" ]; then
  echo "Error: needs AWS_ACCESS_KEY_ID to be set"
  exit 3
fi;

if [ -z "$AWS_SECRET_KEY" ]; then
  echo "Error: needs AWS_SECRET_KEY to be set"
  exit 4
fi;

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
EXTERNAL_PATH="$(realpath "${SCRIPT_PATH}/../external")"
PATH=${PATH}:${SCRIPT_PATH}:${EXTERNAL_PATH}

install-aws.sh > /dev/null 2>&1

aws eks --region "$AWS_REGION" update-kubeconfig --name "$AWS_K8S_CLUSTER_NAME"
