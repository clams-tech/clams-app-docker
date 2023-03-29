#!/bin/bash

set -e
cd "$(dirname "$0")"

. ./defaults.env
. ./.env
#
if docker ps -a | grep -q clams-clightning; then
    docker exec -it -u "$UID:$UID" clams-clightning lightning-cli --network "$BTC_CHAIN" "$@"
else
    echo "ERROR: Cannot find the clightning container. Did you run it?"
    exit 1
fi
