#!/bin/bash

set -ex
cd "$(dirname "$0")"

. ./defaults.env
. ./.env

NODE_PUBKEY=$(./lightning-cli.sh getinfo | jq -r '.id')
echo "$NODE_PUBKEY@$CLAMS_FQDN:$CLIGHTNING_WEBSOCKET_EXTERNAL_PORT"
