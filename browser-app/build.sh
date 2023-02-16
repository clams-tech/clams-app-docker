#!/bin/bash

set -e
cd "$(dirname "$0")"

# shellcheck source=./env
. ./.env

# pull the base image from dockerhub and build the ./Dockerfile.
docker build --build-arg GIT_REPO_URL="$REPO_URL" \
  --build-arg VERSION="$GIT_TAG" \
  -t browser-app:"$GIT_TAG" \
  .
