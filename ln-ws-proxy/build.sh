#!/bin/bash


set -ex
cd "$(dirname "$0")"

# shellcheck source=./env
source ./env

# build the dockerfile.
docker build --build-arg GIT_REPO_URL="$REPO_URL" --build-arg VERSION="$GIT_TAG" -t ln-ws-proxy:"$GIT_TAG" .
