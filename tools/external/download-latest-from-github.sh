#!/usr/bin/env bash

REPO="$1"
FILE="$2"

if [ -z "$REPO" ] || [ -z "$FILE" ]; then
  echo "Usage: $0 USERNAME/REPO FILE_TO_DOWNLOAD"
  exit 1
fi;

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LATEST_RELEASE=$("$SCRIPT_PATH"/get-latest-github-release-version.sh "$REPO")
DOWNLOAD_URL="https://github.com/$REPO/releases/download/$LATEST_RELEASE/$FILE"

wget "$DOWNLOAD_URL" -O "$SCRIPT_PATH/$FILE"