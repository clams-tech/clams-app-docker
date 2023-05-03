#!/bin/bash

until docker ps | grep -q bitcoind; do
    sleep 0.1;
done;

alias bitcoin-cli="bash -c ../bitcoin-cli.sh"

if [ "$BTC_CHAIN" = testnet ] || [ "$BTC_CHAIN" = signet ]; then
    bitcoin-cli createwallet "clams-$BTC_CHAIN" > /dev/null 2>&1
    if [ "$BTC_CHAIN" = regtest ]; then
        # create an on-chain wallet and progress some blocks.
        
        bitcoin-cli -generate 5 > /dev/null 2>&1
    fi
fi


# First lets create a wallet on our backend so we can fund the various CLN nodes.
if ! docker exec -u 1000:1000 -it polar-n1-backend1 [ -f /home/bitcoin/.bitcoin/regtest/wallets/prism ]; then
    bitcoin-cli -regtest createwallet prism
else
    if ! bitcoin-cli -regtest listwallets | grep -q prism; then
        bitcoin-cli -regtest loadwallet prism
    fi
fi

# docker exec -it -u 1000:1000 polar-n1-backend1 bitcoin-cli -regtest getnewaddress
ADDR=$(bitcoin-cli -regtest getnewaddress)
echo "$ADDR"

CMD="bitcoin-cli -regtest generatetoaddress 101 $ADDR"
echo "Please run the following command manually. Afterwards, run resume.sh:  "
echo "$CMD"