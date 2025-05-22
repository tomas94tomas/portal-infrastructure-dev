#!/usr/bin/env bash

ROLE="$1" # secret-reader-binding
USER_ID="$2"
NAMESPACE="$3"

if [[ -z "$NAMESPACE" ]]; then
  NAMESPACE=default
fi

if [[ -z "$ROLE" ]] || [[ -z "$USER_ID" ]]; then
  echo "Syntax: $0 ROLE USER_ID [NAMESPACE]"
  exit 2
fi;

kubectl create rolebinding "${ROLE}-${USER_ID}-binding" --clusterrole="$ROLE" --user="$USER_ID" --namespace="$NAMESPACE"
