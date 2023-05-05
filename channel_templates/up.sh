#!/bin/bash

set -ex
cd "$(dirname "$0")"

# wait for bitcvoind container to startup
until docker ps | grep -q bitcoind; do
    sleep 0.1;
done;

./bitcoind_load_onchain.sh

#./cln_load_onchain.sh

if [ "$BTC_CHAIN" = regtest ]; then
    ./regtest_prism.sh
elif [ "$BTC_CHAIN" = regtest ]; then
    echo "calling signet_prism setup."
fi