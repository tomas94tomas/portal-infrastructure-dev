#!/usr/bin/env bash

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PATH=$PATH:${SCRIPT_PATH}

install-helm.sh > /dev/null 2>&1

# This script updates required helm plugins
# It is needed because sometimes helm doesn't try to upgrade to latest

LATEST_RELEASE=$("$SCRIPT_PATH"/get-latest-github-release-version.sh "jkroepke/helm-secrets")
LATEST_RELEASE_WITHOUT_V=${LATEST_RELEASE#v}
CURRENT_RELEASE=$(helm secrets -v 2>&1)
if [[ "$CURRENT_RELEASE" != "$LATEST_RELEASE_WITHOUT_V" ]]; then
  echo "secrets not latest. Updating..."
  helm plugin uninstall secrets
  helm plugin install https://github.com/jkroepke/helm-secrets --version "${LATEST_RELEASE}"
else
  echo "'secrets' plugin already latest. Not updating."
fi;
