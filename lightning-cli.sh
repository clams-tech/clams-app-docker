#!/bin/bash

set -e
cd "$(dirname "$0")"

. ./defaults.env
. ./.env

CLN_ID=0

# TODO add argument to specify CLN NODE ID

if docker ps | grep -q "clams-stack_cln-${CLN_ID}"; then
    CLN_CONTAINER_ID="$(docker ps | grep "clams-stack_cln-${CLN_ID}" | head -n1 | awk '{print $1;}')"
    docker exec -it "$CLN_CONTAINER_ID" lightning-cli --network "$BTC_CHAIN" "$@"
else
    echo "ERROR: Cannot find the clightning container. Did you run it?"
    exit 1
fi
