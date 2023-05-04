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
if [ -f "$ENV_FILE_PATH" ]; then
    source "$ENV_FILE_PATH"
fi

if docker ps | grep -q bitcoind; then
    BITCOIND_CONTAINER_ID="$(docker ps | grep bitcoind | head -n1 | awk '{print $1;}')"
    docker exec -it -u "$UID:$UID" "$BITCOIND_CONTAINER_ID" bitcoin-cli -"$BTC_CHAIN" "$@"
else
    echo "ERROR: Cannot find the bitcoind container. Did you run it?"
    exit 1
fi 
