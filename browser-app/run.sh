#!/bin/bash

set -e
cd "$(dirname "$0")"

OUTPUT_DIR="$(pwd)/www-root"

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

# shellcheck source=./env
. ./.env

# build the docker image.
./build.sh

# If the existing output directory exists, we delete it so we can get fresh files.
if [ ! -d "$OUTPUT_DIR" ]; then
    mkdir -p "$OUTPUT_DIR"

fi

IMAGE_NAME="browser-app:$GIT_TAG"

# if the image is built, execute it and we get our output.
if docker image list --format "{{.Repository}}:{{.Tag}}" | grep -q "$IMAGE_NAME"; then
    docker run -t --rm --user "$UID:$UID" -v "$OUTPUT_DIR":/output --name browser-app browser-app:"$GIT_TAG"
fi

# bring the nginx container up to expose the Clams Browser App service.
docker compose up -d 
echo "The Clams Browser App is available at http://${BROWSER_APP_BIND_ADDR}:${BROWSER_APP_PORT}"
