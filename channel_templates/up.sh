#!/bin/bash

set -e
cd "$(dirname "$0")"

# wait for bitcvoind container to startup
until docker ps | grep -q bitcoind; do
    sleep 0.1;
done;

# set these funcs and vars here for testing
lncli() {
    "$(dirname "$0")/../lightning-cli.sh" "$@"
}

bcli() {
    "$(dirname "$0")/../bitcoin-cli.sh" "$@"
}

CLN_COUNT=5
BTC_CHAIN=regtest

export -f lncli
export -f bcli
export CLN_COUNT
export BTC_CHAIN

./bitcoind_load_onchain.sh

./cln_load_onchain.sh

./bootstrap_p2p.sh

# now open channels depending on the setup.
if [ "$BTC_CHAIN" = regtest ]; then
    ./regtest_prism.sh
fi