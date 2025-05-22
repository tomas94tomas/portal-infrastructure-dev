#!/usr/bin/env bash

resolve_aws_access_key_id() {
  if [ -z "$TF_AWS_ACCESS_KEY_ID" ]; then
      # shellcheck disable=SC2153
      echo "$AWS_ACCESS_KEY_ID"
  else
      echo "$TF_AWS_ACCESS_KEY_ID"
  fi;
}

resolve_aws_secret_access_key() {
  if [ -z "$TF_AWS_SECRET_ACCESS_KEY" ]; then
      # shellcheck disable=SC2153
      echo "$AWS_SECRET_ACCESS_KEY"
  else
      echo "$TF_AWS_SECRET_ACCESS_KEY"
  fi;
}

exec_in_correct_env() {
  local aws_access_key_id
  local aws_secret_access_key

  aws_access_key_id=$(resolve_aws_access_key_id)
  aws_secret_access_key=$(resolve_aws_secret_access_key)

  AWS_ACCESS_KEY_ID="$aws_access_key_id" AWS_SECRET_ACCESS_KEY="$aws_secret_access_key" "$@"
}

exec_in_correct_env "$@"
