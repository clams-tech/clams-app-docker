#!/bin/bash

# the purpose of this script is to ensure the bitcoind
# node has plenty of on-chain funds upon which to fund the CLN nodes.

set -ex
cd "$(dirname "$0")"

bcli() {
    "../bitcoin-cli.sh" "$@"
}

#set this var here for testing
BTC_CHAIN=regtest

#first we need to check if the prism wallet exists in the wallet dir
if [[ $(bcli listwalletdir) == *'"name": "prism"'* ]]; then
    #if it exists, then check if it's loaded
    if bcli listwallets | grep -q "prism"; then
        echo "Wallet is already loaded"
    else
        bcli loadwallet "prism"
    fi
else
    #create walllet if it does not already exist
    bcli createwallet prism
fi

#create address controlled by our wallet
#bcrt1qqd7yn0wll8vx0lxe2sdh224dqathne0f3fefa2
#BTC_ADDRESS=$(bcli getnewaddress | xargs)
BTC_ADDRESS=bcrt1qqd7yn0wll8vx0lxe2sdh224dqathne0f3fefa2
#$(bcli getnewaddress | xargs)
# The above command will only work if only one wallet it loaded
#TODO: specify which wallet to target
#error message:
#Wallet file not specified (must request wallet RPC through /wallet/<filename> uri-path).
#Try adding "-rpcwallet=<filename>" option to bitcoin-cli command line.
echo "BTC_ADDRESS: $BTC_ADDRESS"


#if regtest, check that there are at least 101 blocks
if [ "$BTC_CHAIN" == regtest ]; then
    num_blocks=$(bcli getblockchaininfo | jq '.blocks')

    if ((num_blocks < 101)); then
        bcli generatetoaddress 101 "$BTC_ADDRESS"
    fi

    #check wallet balance
    wallet_balance=$(bcli getwalletinfo | jq '.balance')
    if ((wallet_balance < 5)); then
        bcli generatetoaddress 1 "$BTC_ADDRESS"
    fi
fi