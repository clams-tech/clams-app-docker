#!/bin/bash


set -ex
cd "$(dirname "$0")"

# shellcheck source=./env
source ./env

if docker ps | grep -q "$REPO_NAME"; then
    docker kill "$REPO_NAME"
fi

if docker ps -a | grep -q "$REPO_NAME"; then
    docker system prune -f
fi

# build the dockerfile.
docker build --build-arg GIT_REPO_URL="$REPO_URL" --build-arg VERSION="$GIT_TAG" -t "$REPO_NAME":"$GIT_TAG" .

# run the service.
docker run -d \
    --name "$REPO_NAME" \
    -p 127.0.0.1:3000:3000 \
    "$REPO_NAME":"$GIT_TAG"
