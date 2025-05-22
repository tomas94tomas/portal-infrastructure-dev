#!/usr/bin/env bash

ROLE="$1" # secret-reader-binding
USER_ID="$2"

if [[ -z "$ROLE" ]] || [[ -z "$USER_ID" ]]; then
  echo "Syntax: $0 ROLE USER_ID [NAMESPACE]"
  exit 2
fi;

kubectl create clusterrolebinding "${ROLE}-${USER_ID}-binding" --clusterrole="$ROLE" --user="$USER_ID"
