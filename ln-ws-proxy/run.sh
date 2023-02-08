#!/bin/bash

set -e
cd "$(dirname "$0")"

# run the build script.
./build.sh

. ./env

# run the service.
docker run -d \
    --name ln-ws-proxy \
    -p 127.0.0.1:3000:3000 \
    ln-ws-proxy:"$GIT_TAG"
