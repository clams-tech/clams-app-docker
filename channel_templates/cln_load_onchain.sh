#!/bin/bash

# the purpose of this script is to ensure that all CLN nodes have on-chain funds.
# assumes bitcoind has a loaded wallet with spendable funds

set -e

# fund each cln node
for ((CLN_ID=0; CLN_ID<CLN_COUNT; CLN_ID++)); do

    #check that we have at least 5 btc
    if [ "$BALANCE" -ge 500000000000 ]; then
        echo "cln-$i has sufficient funds: $BALANCE mSats"
    else
        echo "Insufficient funds. Sending 5 btc to cln-$i"
        CLN_ADDR=$(lncli --id="$i" newaddr | jq -r '.bech32')
    echo "Insufficient funds. Sending 5 btc to cln-$CLN_ID"
        bcli -generate 1 > /dev/null

    if [ "$CLN_ID" = 1 ]; then
        bcli sendtoaddress "$CLN_ADDR" 5 > /dev/null
        bcli sendtoaddress "$CLN_ADDR" 5 > /dev/null
        bcli sendtoaddress "$CLN_ADDR" 5 > /dev/null
        bcli sendtoaddress "$CLN_ADDR" 5 > /dev/null
        bcli sendtoaddress "$CLN_ADDR" 5 > /dev/null
    else
        bcli sendtoaddress "$CLN_ADDR" 5 > /dev/null
    fi

    bcli -generate 10 > /dev/null

done
