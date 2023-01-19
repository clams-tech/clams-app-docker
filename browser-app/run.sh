#!/bin/bash

set -e
cd "$(dirname "$0")"

# read in the variable from the files in ./
source ./env

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

if docker ps | grep -q "$REPO_NAME"; then
    docker kill "$REPO_NAME"
fi

if docker ps -a | grep -q "$REPO_NAME"; then
    docker system prune -f
fi

# build the dockerfile.
docker pull node:latest
docker build --build-arg GIT_REPO_URL="$REPO_URL" --build-arg VERSION="$GIT_TAG" -t browser-app:"$GIT_TAG" .

################

# If the existing output directory exists, we delete it so we can get fresh files.
if [ -d "$OUTPUT_DIR" ]; then
    sudo rm -rf "$OUTPUT_DIR"
    echo "INFO: Your existing output files have been deleted."
fi

echo "Creating '$OUTPUT_DIR'."
mkdir "$OUTPUT_DIR"

# copy the files from the build process to OUTPUT_DIR
docker run -it -v "$OUTPUT_DIR":/output --name browser-app "$REPO_NAME":"$GIT_TAG"

# TODO remove; see if we can get UID mapped
sudo chown -R "$USER:$USER" "$OUTPUT_DIR"

docker system prune -f >> /dev/null

echo "Your static files for Clams browser app can be found at ${OUTPUT_DIR}"
