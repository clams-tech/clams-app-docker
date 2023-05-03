#!/bin/bash

set -e
cd "$(dirname "$0")"

# # build the ln-ws-app if we're deploying it.
# LN_WS_PROXY_IMAGE_NAME="ln-ws-proxy:$LN_WS_PROXY_GIT_TAG"
# export LN_WS_PROXY_IMAGE_NAME="$LN_WS_PROXY_IMAGE_NAME"
# if [ "$DEPLOY_LN_WS_PROXY" = true ]; then
#     docker build --build-arg GIT_REPO_URL="$LN_WS_PROXY_GIT_REPO_URL" \
#     --build-arg VERSION="$LN_WS_PROXY_GIT_TAG" \
#     -t "$LN_WS_PROXY_IMAGE_NAME" \
#     ./ln-ws-proxy/
# fi
