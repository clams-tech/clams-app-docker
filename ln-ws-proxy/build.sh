#!/bin/bash


set -e
cd "$(dirname "$0")"

# shellcheck source=./.env
. ./.env

# build the dockerfile.
docker build --build-arg GIT_REPO_URL="$REPO_URL" --build-arg VERSION="$GIT_TAG" -t ln-ws-proxy:"$GIT_TAG" .
