#!/bin/bash

set -ex
cd "$(dirname "$0")"

# the purpose of script is to build the docker images for the clams-tech Clams stack.

docker pull node:latest

source ./env

if docker ps | grep -q "$REPO_NAME"; then
    docker kill "$REPO_NAME"
fi

if docker ps -a | grep -q "$REPO_NAME"; then
    docker system prune -f
fi

# build the dockerfile.
docker build  --build-arg GIT_REPO_URL="$REPO_URL" --build-arg VERSION="$GIT_TAG" -t "$REPO_NAME":"$GIT_TAG" .
