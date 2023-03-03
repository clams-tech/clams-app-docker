#!/bin/bash

set -ex
cd "$(dirname "$0")"

# this script brings up the backend needed (i.e., lightningd+bitcoind) to test Clams app

. ./.env

IS_REGTEST=0
IS_TESTNET=0

CLIGHTNING_CHAIN="$BTC_CHAIN"

# defaults are for regtest
BITCOIND_RPC_PORT=18443

if [ "$BTC_CHAIN" = testnet ]; then
    IS_TESTNET=1
    BITCOIND_RPC_PORT=18332
elif [ "$BTC_CHAIN" = mainnet ]; then
    CLIGHTNING_CHAIN=bitcoin
    BITCOIND_RPC_PORT=8332
else
    IS_REGTEST=1
fi

export IS_REGTEST="$IS_REGTEST"
export IS_TESTNET="$IS_TESTNET"
export CLIGHTNING_CHAIN="$CLIGHTNING_CHAIN"
export BITCOIND_RPC_PORT="$BITCOIND_RPC_PORT"

mkdir -p ./volumes

env IS_REGTEST="$IS_REGTEST" IS_TESTNET="$IS_TESTNET" CLIGHTNING_CHAIN="$CLIGHTNING_CHAIN" BITCOIND_RPC_PORT="$BITCOIND_RPC_PORT" docker compose up -d

echo "bitcoind and core lightning are now running. Your core lightning websocket address is ws://${WEBSOCKET_BIND_ADDR}:${WEBSOCKET_PORT}"

sleep 5

# the purpose of this script is the return the URI needed by people testing Clams app.
if ! docker ps | grep -q clams-bitcoind; then
    echo "ERROR: something went wrong. We couldn't find the bitcoind container."
    exit 1
fi

# get the bitcoind container then load a wallet and generate some blocks
docker exec -it -u "$UID:$UID" clams-bitcoind bitcoin-cli -"$CLIGHTNING_CHAIN" createwallet clams >/dev/null 2>&1
docker exec -it -u "$UID:$UID" clams-bitcoind bitcoin-cli -"$CLIGHTNING_CHAIN" -generate 5 >/dev/null 2>&1
