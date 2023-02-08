#!/bin/bash

set -ex
cd "$(dirname "$0")"

# shellcheck source=./env
source ./env

if docker ps | grep -q browser-app; then
    docker kill browser-app
fi

if docker ps -a | grep -q browser-app; then
    docker system prune -f
fi


# pull the base image from dockerhub and build the ./Dockerfile.
docker build --build-arg GIT_REPO_URL="$REPO_URL" \
  --build-arg VERSION="$GIT_TAG" \
  --build-arg UID="$UID" \
  --build-arg GUID="$UID" \
  -t browser-app:"$GIT_TAG" \
  .

