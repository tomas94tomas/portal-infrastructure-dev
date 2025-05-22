#!/usr/bin/env bash

if ! type -a kubectl &>/dev/null; then
  KUBECTL_CMD="minikube kubectl --"
else
  KUBECTL_CMD="kubectl"
fi;

$KUBECTL_CMD "$@"