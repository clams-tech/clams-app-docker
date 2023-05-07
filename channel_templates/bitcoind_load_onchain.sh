#!/bin/bash

# the purpose of this script is to ensure the bitcoind
# node has plenty of on-chain funds upon which to fund the CLN nodes.

set -e
cd "$(dirname "$0")"


#first we need to check if the prism wallet exists in the wallet dir
if [[ $(bcli listwalletdir) == *'"name": "prism"'* ]]; then
    # load wallet if not already loaded
    if ! bcli listwallets | grep -q "prism"; then
        bcli loadwallet "prism"
    fi
else
    #create walllet (gets loaded automatically) if it does not already exist
    bcli createwallet prism
fi

WALLET_INFO=$(bcli getwalletinfo)
# The above command will only work if only one wallet it loaded
# TODO: specify which wallet to target
# error message:
# Wallet file not specified (must request wallet RPC through /wallet/<filename> uri-path).
# Try adding "-rpcwallet=<filename>" option to bitcoin-cli command line.
WALLET_BALANCE=$(echo "$WALLET_INFO" | jq -r '.balance')
WALLET_NAME=$(echo "$WALLET_INFO" | jq -r '.walletname')

echo "$WALLET_NAME wallet initialized"

if [ "$(echo "$WALLET_BALANCE < 5" | bc -l) " -eq 1 ]; then
#create address controlled by our wallet
#bcrt1qqd7yn0wll8vx0lxe2sdh224dqathne0f3fefa2
BTC_ADDRESS=$(bcli getnewaddress)
CLEAN_BTC_ADDRESS=$(echo -n "$BTC_ADDRESS" | tr -d '\r')
echo "BTC_ADDRESS: $CLEAN_BTC_ADDRESS"
echo "Make sure that the above address is created from your wallet"
    if [ "$BTC_CHAIN" == regtest ]; then
        bcli generatetoaddress 101 $CLEAN_BTC_ADDRESS
        echo "101 blocks mined to $WALLET_NAME"
    else 
        echo "ERROR: You are on $BTC_CHAIN and cannot generate coins to your wallet. Figure out how to get some onchain funds"
        exit 1
    fi
else
    echo "Wallet has sufficient funds: $WALLET_BALANCE BTC"
fi
