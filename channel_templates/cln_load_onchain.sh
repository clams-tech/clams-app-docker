#!/bin/bash

# the purpose of this script is to ensure that all CLN nodes have on-chain funds.
# assumes bitcoind has a loaded wallet with spendable funds


set -e


# fund each cln node
for ((i=0; i<CLN_COUNT; i++)); do
    BALANCE=$(lncli --id="$i" bkpr-listbalances | jq -r '.accounts[0].balances[0].balance_msat[:-4] | tonumber')

    #check that we have at least .25 btc
    if [ "$BALANCE" -ge 25000000000 ]; then
        echo "cln-$i has sufficient funds: $BALANCE mSats"
    else
        echo "Insufficient funds. Sending 1 btc to cln-$i"
        CLN_ADDR=$(lncli --id="$i" newaddr | jq -r '.bech32')
        bcli sendtoaddress "$CLN_ADDR" 1
        bcli -generate 1 > /dev/null
    fi
done
