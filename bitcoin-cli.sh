#!/bin/bash

set -e
cd "$(dirname "$0")"

. ./.env

if docker ps | grep -q bitcoind; then
    BITCOIND_CONTAINER_ID="$(docker ps | grep bitcoind | head -n1 | awk '{print $1;}')"
    docker exec -it -u "$UID:$UID" "$BITCOIND_CONTAINER_ID" bitcoin-cli -"$BTC_CHAIN" "$@"
else
    echo "ERROR: Cannot find the bitcoind container. Did you run it?"
    exit 1
fi 
