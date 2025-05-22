#!/usr/bin/env bash

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

IMAGE="$1"
ENVIRONMENT="$2"

touch all.log
echo "$0 $IMAGE $ENVIRONMENT" >> all.log

if [[ -z "$IMAGE" ]]; then
  echo "Syntax: $0 DOCKER_IMAGE_NAME:TAG [ENVIRONMENT]"
fi;

if [[ -z "$ENVIRONMENT" ]]; then
  ENVIRONMENT=development
fi;

PATH=$PATH:${SCRIPT_PATH}/../external

install-jq.sh > /dev/null 2>&1

INSPECT_RESPONSE=$(docker manifest inspect -v "$IMAGE" 2>/dev/null)

FILTER='.manifests[] | select(.platform.os == "linux" and .platform.architecture == "amd64") | .digest'
OUT=$(echo "$INSPECT_RESPONSE" | jq -r "$FILTER" 2>/dev/null)

if [ -z "$OUT" ]; then
  OUT=$(echo "$INSPECT_RESPONSE" | jq -r ".Descriptor.digest")
fi;

if [[ -z "$OUT" ]]; then
  echo "none:";
else
  echo "$OUT";
fi;
