#!/bin/bash

set -e
cd "$(dirname "$0")"

. ./defaults.env

ENV_FILE_PATH=$(pwd)/environments/local.env

# grab any modifications from the command line.
for i in "$@"; do
    case $i in
        --env-file-path=*)
            ENV_FILE_PATH="${i#*=}"
            shift
        ;;
        *)
        ;;
    esac
done


# source the 
if [ ! -f "$ENV_FILE_PATH" ]; then
    echo "ERROR: ENV_FILE_PATH '$ENV_FILE_PATH' does not exist."
    exit 1
fi

source "$ENV_FILE_PATH"


NODE_ID=0

# grab any modifications from the command line.
for i in "$@"; do
    case $i in
        --id=*)
            NODE_ID="${i#*=}"
            shift
        ;;
        *)

        ;;
    esac
done

if docker ps | grep -q "clams-stack_cln-${NODE_ID}"; then
    CLN_CONTAINER_ID="$(docker ps | grep "clams-stack_cln-${NODE_ID}" | head -n1 | awk '{print $1;}')"
    docker exec -it "$CLN_CONTAINER_ID" lightning-cli --network "$BTC_CHAIN" "$@"
else
    echo "ERROR: Cannot find the clightning container. Did you run it?"
    exit 1
fi
