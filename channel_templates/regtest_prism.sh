#!/bin/bash

set -ex

names=(alice bob carol dave erin frank greg hannah ian jane kelly laura mario nick olivia)

# dynamically set each name to the output of getinfo
for ((i=0; i<CLN_COUNT; i++)); do
    var_name=${names[$i]}
    node_info=$(lncli --id="$i" getinfo)
    eval "${var_name}=\$node_info"
done

for ((i=0; i<CLN_COUNT; i++)); do 
    echo "${names[$i]} pubkey is $(echo "${!names[$i]}" | jq -r ".id")"
done

# echo "Bob: $bob"
# echo "Carol: $carol"


# this script creates channels among 5 nodes in the following way:
    # 1.  Alice[0]->Bob[1]
    # 2.  Bob[1]->Carol[2]
    # 3.  Bob[1]->Dave[3]
    # 4.  Bob[1]->Erin[4]


# Lets first get pubkeys for all nodes
# ALICE_PUBKEY=$(lncli --id=0 getinfo | jq -r ".id")
# BOB_PUBKEY=$(lncli --id=1 getinfo | jq -r ".id")
# CAROL_PUBKEY=$(lncli --id=2 getinfo | jq -r ".id")
# DAVE_PUBKEY=$(lncli --id=3 getinfo | jq -r ".id")
# ERIN_PUBKEY=$(lncli --id=4 getinfo | jq -r ".id")


# now lets wire them up

# #  Alice & Bob
# lncli --id=0 connect $BOB_PUBKEY <ip> 9735

# # Bob & Carol
# lnccli --id=1 connect $CAROL_PUBKEY <ip> 9735

# # Bob & Dave
# lnccli --id=1 connect $DAVE_PUBKEY <ip> 9735

# #Bob & Erin
# lnccli --id=1 connect $ERIN_PUBKEY <ip> 9735

# # Erin back to Alice just for fun
# lnccli --id=4 connect $ALICE_PUBKEY <ip> 9735


# time to fund each of these connections (amounts in msats)

# # Alice --> Bob
# lncli --id=0 fundchannel "$BOB_PUBKEY" $((50000000 * 1000))

# # Bob --> Carol
# lncli --id=1 fundchannel "$CAROL_PUBKEY" $((25000000 * 1000))

# # Bob --> Dave
# lncli --id=1 fundchannel "$DAVE_PUBKEY" $((25000000 * 1000))

# #  Bob --> Erin
# lncli --id=1 fundchannel "$ERIN_PUBKEY" $((25000000 * 1000))

# # Erin --> Alice
# lncli --id=4 fundchannel "$ALICE_PUBKEY" $((25000000 * 1000))

# ASSUMPTIONS: we assume in this script that all the Lightning nodes have on-chain funds!

echo "TODO: regtest_prism.sh"