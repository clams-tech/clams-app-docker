#!/bin/bash

set -e

# get node pubkeys
#ALICE_PUBKEY=$(lncli --id=0 getinfo | jq -r ".id")
BOB_PUBKEY=$(lncli --id=1 getinfo | jq -r ".id")
CAROL_PUBKEY=$(lncli --id=2 getinfo | jq -r ".id")
DAVE_PUBKEY=$(lncli --id=3 getinfo | jq -r ".id")
ERIN_PUBKEY=$(lncli --id=4 getinfo | jq -r ".id")

# now lets wire them up
# Alice --> Bob
lncli --id=0 fundchannel "$BOB_PUBKEY" $((25000000 * 1000))

# Bob --> Carol
lncli --id=1 fundchannel "$CAROL_PUBKEY" $((25000000 * 1000))

# Bob --> Dave
lncli --id=1 fundchannel "$DAVE_PUBKEY" $((25000000 * 1000))

#  Bob --> Erin
lncli --id=1 fundchannel "$ERIN_PUBKEY" $((25000000 * 1000))
