#!/bin/bash

set -e
cd "$(dirname "$0")"


source ./.env

NODE_PUBKEY=
if docker ps -a | grep -q clams-clightning; then
    NODE_PUBKEY=$(docker exec -it -u "$UID:$UID" clams-clightning lightning-cli --network "$BTC_CHAIN" getinfo | jq -r '.id')
else
    echo "ERROR: Cannot find the clightning container. Did you run it?"
    exit 1
fi

source ./backend/.env

echo "Your node connection details are:"
echo "core-lightning websocket \"Direct Connection (ws)\": $NODE_PUBKEY@$WEBSOCKET_BIND_ADDR:$WEBSOCKET_PORT"
