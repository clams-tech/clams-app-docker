#!/bin/bash

set -ex
cd "$(dirname "$0")"

# the purpose of script is to build the docker images for the clams-tech Clams stack.

docker pull node:latest

# TODO need to ask Clams guys to tag the ln-ws-proxy repo.
#GIT_TAG="1.3.0"

if docker ps | grep -q ln-ws-proxy; then
    docker kill ln-ws-proxy
fi

if docker ps -a | grep -q ln-ws-proxy; then
    docker system prune -f
fi

# build the dockerfile.
docker build -t ln-ws-proxy:"$GIT_TAG" .
