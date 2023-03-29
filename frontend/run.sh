#!/bin/bash

set -e
cd "$(dirname "$0")"

OUTPUT_DIR=

# grab any modifications from the command line.
for i in "$@"; do
    case $i in
        --output-path=*)
            OUTPUT_DIR="${i#*=}"
            shift
        ;;
        *)
        echo "Unexpected option: $1"
        exit 1
        ;;
    esac
done

# check to see if we have certificates
if [ "$ENABLE_TLS" = true ]; then
    ./getrenew_cert.sh
fi

BROWSER_APP_IMAGE_NAME="browser-app:$BROWSER_APP_GIT_TAG"
if [ "$DEPLOY_BROWSER_APP" = true ]; then
    # build the browser-app image.
    # pull the base image from dockerhub and build the ./Dockerfile.
    if ! docker image list --format "{{.Repository}}:{{.Tag}}" | grep -q "$BROWSER_APP_IMAGE_NAME"; then
        docker build --build-arg GIT_REPO_URL="$BROWSER_APP_GIT_REPO_URL" \
        --build-arg VERSION="$BROWSER_APP_GIT_TAG" \
        -t "$BROWSER_APP_IMAGE_NAME" \
        ./browser-app/
    fi
fi

# If the existing output directory exists, we delete it so we can get fresh files.
if [ -n "$OUTPUT_DIR" ]; then
    mkdir -p "$OUTPUT_DIR"
    # if the image is built, execute it and we get our output
    docker run -t --rm --user "$UID:$UID" -v "$OUTPUT_DIR":/output --name browser-app "$BROWSER_APP_IMAGE_NAME"
else
    docker volume create www-root
    docker run -t --rm -v www-root:/output --name browser-app "$BROWSER_APP_IMAGE_NAME"
fi


# build the ln-ws-app if we're deploying it.
LN_WS_PROXY_IMAGE_NAME="ln-ws-proxy:$LN_WS_PROXY_GIT_TAG"
export LN_WS_PROXY_IMAGE_NAME="$LN_WS_PROXY_IMAGE_NAME"
if [ "$DEPLOY_LN_WS_PROXY" = true ]; then
    docker build --build-arg GIT_REPO_URL="$LN_WS_PROXY_GIT_REPO_URL" \
    --build-arg VERSION="$LN_WS_PROXY_GIT_TAG" \
    -t "$LN_WS_PROXY_IMAGE_NAME" \
    ./ln-ws-proxy/
fi


# stub out the nginx config
NGINX_CONFIG_PATH="$(pwd)/nginx.conf"
export NGINX_CONFIG_PATH="$NGINX_CONFIG_PATH"

touch "$NGINX_CONFIG_PATH"

# create the nginx.conf file.
./stub_nginx_conf.sh

# now build the docker-compose.yml file
./stub_docker_compose.sh


docker volume create clams-certs

# bring the nginx container up to expose the Clams Browser App service.
docker compose up -d
