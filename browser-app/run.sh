#!/bin/bash

set -ex
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
source ./env

# If the existing output directory exists, we delete it so we can get fresh files.
if [ -d "$OUTPUT_DIR" ]; then
    rm -rf "$OUTPUT_DIR"
    echo "INFO: Your existing output files have been deleted."
fi

./build.sh

mkdir -p "$OUTPUT_DIR"

docker run -t --rm --user "$UID:$UID" -v "$OUTPUT_DIR":/output --name browser-app browser-app:"$GIT_TAG"
