#!/bin/bash

set -ex
cd "$(dirname "$0")"

# purpose of script is to build the docker images for the clams-tech Clams stack.
# 

docker pull node:latest

for APP in browser-app lnsocket-proxy; do
    if docker ps | grep -q "$APP"; then
        docker kill "$APP"
    fi

    if docker ps -a | grep -q "$APP"; then
        docker system prune -f
    fi

    docker build -t clams:latest ./"$APP"/
done
