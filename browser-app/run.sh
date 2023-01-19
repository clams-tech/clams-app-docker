#!/bin/bash

set -e
cd "$(dirname "$0")"

source "$(pwd)/env"

# TODO take OUTPUT_DIR as argument from CLI.

OUTPUT_DIR="$(pwd)/www-root"

# this runs the web server
if [ -d "$OUTPUT_DIR" ]; then
    sudo rm -rf "$OUTPUT_DIR"
    echo "INFO: Your existing output files have been deleted."
    sleep 3
fi

mkdir "$OUTPUT_DIR"

docker run -it -v "$OUTPUT_DIR":/output --name browser-app "$REPO_NAME":"$GIT_TAG"

sudo chown -R "$USER:$USER" "$OUTPUT_DIR"

docker system prune -f >> /dev/null

echo "Your static files for Clams browser app can be found at ${OUTPUT_DIR}"
