#!/usr/bin/env bash

REPO="$1"

if [ -z "$REPO" ]; then
  echo "Usage: $0 USERNAME/REPO"
  exit 1
fi;

LATEST_RELEASE_URL="https://api.github.com/repos/$REPO/releases/latest"
curl -sSL "$LATEST_RELEASE_URL" | grep -Po '"tag_name": "\K.*?(?=")'