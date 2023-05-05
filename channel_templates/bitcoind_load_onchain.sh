#!/bin/bash

# the purpose of this script is to ensure the bitcoind 
# node has plenty of on-chain funds upon which to fund all the CLN nodes.


set -ex


bcli() {
    bash -c "../bitcoin-cli.sh $@"
}


#first we need to check if the prism wallet exists in the wallet dir
if [[ $(bcli listwalletdir) == *'"name": "prism"'* ]]; then
    #if it exists, then check if it's loaded
    if bcli listwallets | grep -q "test"; then
        echo "Wallet is already loaded"
    else
        bcli loadwallet "prism.dat"
    fi
else
    #create walllet if it does not already exist
    bcli createwallet wallet_name="prism" load_on_startup=true #not working, returning error code: -1
fi


#create address controlled by our wallet
BTC_ADDRESS=$(bcli getnewaddress) #must request wallet RPC through /wallet/<filename> uri-path).
                                        # try adding "-rpcwallet=<filename>" option to bitcoin-cli command line

#if regtest, check that there are at least 101 blocks
if [ "$BTC_CHAIN" = regtest]; then
    num_blocks=$(bcli getblockchaininfo | jq '.blocks')

    if ((num_blocks < 101)); then
        bcli generatetoaddress 101 $BTC_ADDRESS
    fi

    #check wallet balance
    wallet_balance=$(bcli getwalletinfo | jq '.balance')
    if ((wallet_balance < 5)); then
        bcli generatetoaddress 1 $BTC_ADDRESS
    fi
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