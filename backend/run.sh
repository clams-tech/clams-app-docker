#!/bin/bash

set -e
cd "$(dirname "$0")"

# this script brings up the backend needed (i.e., lightningd+bitcoind) to test Clams app

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

WEBSOCKET_PORT_LOCAL=
P2P_PORT_PORT=9735
CLIGHTNING_LOCAL_BIND_ADDR=
if [ "$ENABLE_TLS" = false ]; then
    WEBSOCKET_PORT_LOCAL="$CLIGHTNING_WEBSOCKET_EXTERNAL_PORT"
    P2P_PORT_PORT="$CLIGHTNING_P2P_EXTERNAL_PORT"
else
    WEBSOCKET_PORT_LOCAL=9736
    CLIGHTNING_LOCAL_BIND_ADDR="127.0.0.1"
fi

export P2P_PORT_PORT="$P2P_PORT_PORT"
export WEBSOCKET_PORT_LOCAL="$WEBSOCKET_PORT_LOCAL"
export CLIGHTNING_LOCAL_BIND_ADDR="$CLIGHTNING_LOCAL_BIND_ADDR"

# create docker volumes
for VOLUME in clightning bitcoind; do
    if ! docker volume list --format csv | grep -q "$VOLUME"; then
        docker volume create "$VOLUME"
    fi
done

docker compose up -d

sleep 6

until docker ps | grep -q clams-bitcoind; do
    sleep 0.1;
done;

# get the bitcoind container then load a wallet and generate some blocks
bash -c "../bitcoin-cli.sh createwallet Clams" 
#> /dev/null 2>&1
bash -c "../bitcoin-cli.sh -generate 5"
#> /dev/null 2>&1
