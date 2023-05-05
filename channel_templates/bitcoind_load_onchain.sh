#!/bin/bash

# the purpose of this script is to ensure the bitcoind 
# node has plenty of on-chain funds upon which to fund all the CLN nodes.


set -ex

bcli() {
    "$(dirname "$0")/../bitcoin-cli.sh" "$@"
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
BTC_ADDRESS=$(bcli getnewaddress)
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
        CMD="$(dirname "$0")/../bitcoin-cli.sh generatetoaddress 101 $BTC_ADDRESS"
        echo "Please execute the following command:"
        echo "$CMD"
    fi

    #check wallet balance
    wallet_balance=$(bcli getwalletinfo | jq '.balance')
    if ((wallet_balance < 5)); then
        CMD="$(dirname "$0")/../bitcoin-cli.sh generatetoaddress 1 $BTC_ADDRESS"
        echo "Please execute the following command:"
        echo "$CMD"
    fi
else
    echo "Not in regtest"
fi







# if [ "$BTC_CHAIN" = testnet ] || [ "$BTC_CHAIN" = signet ]; then
#     bcli createwallet "clams-$BTC_CHAIN" > /dev/null 2>&1
#     if [ "$BTC_CHAIN" = regtest ]; then
#         # create an on-chain wallet and progress some blocks.
        
#         bcli -generate 5 > /dev/null 2>&1
#     fi
# fi

# docker exec -it -u 1000:1000 polar-n1-backend1 bcli -regtest getnewaddress
# ADDR=$(bcli -regtest getnewaddress)
# echo "$ADDR"

# CMD="bcli -regtest generatetoaddress 101 $ADDR"
# echo "Please run the following command manually. Afterwards, run resume.sh:  "
# echo "$CMD"