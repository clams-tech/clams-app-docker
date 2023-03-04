#!/bin/bash

set -e
cd "$(dirname "$0")"

. ./defaults.env
. ./.env

NODE_PUBKEY=$(docker exec -it -u "$UID:$UID" clams-clightning lightning-cli --network "$BTC_CHAIN" getinfo | jq -r '.id')
echo "$NODE_PUBKEY@$CLAMS_FQDN:$CLIGHTNING_WEBSOCKET_EXTERNAL_PORT"
