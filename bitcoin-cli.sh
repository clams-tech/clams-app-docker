#!/bin/bash

set -e
cd "$(dirname "$0")"

. ./.env

if docker ps -a | grep -q clams-bitcoind; then
    docker exec -it -u "$UID:$UID" clams-bitcoind bitcoin-cli -"$BTC_CHAIN" "$@"
else
    echo "ERROR: Cannot find the bitcoind container. Did you run it?"
    exit 1
fi 
