#!/bin/bash

# the purpose of this script is to ensure that all CLN nodes have on-chain funds.
# assumes bitcoind has a loaded wallet with spendable funds

set -e

# fund each cln node
for ((CLN_ID=0; CLN_ID<CLN_COUNT; CLN_ID++)); do
    BALANCE_MSAT_STR=$(lncli --id="$CLN_ID" bkpr-listbalances | jq -r '.accounts[0].balances[0].balance_msat')
    BALANCE_MSAT=${BALANCE_MSAT_STR%msat}

    #check that we have at least 5 btc
    if (("$BALANCE_MSAT" > 500000000000 )); then
        echo "INFO: cln-$CLN_ID has sufficient funds: $BALANCE_MSAT mSats"
        continue
    fi

    echo "Insufficient funds. Sending 5 btc to cln-$CLN_ID"
    CLN_ADDR=$(lncli --id="$CLN_ID" newaddr | jq -r '.bech32')

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
