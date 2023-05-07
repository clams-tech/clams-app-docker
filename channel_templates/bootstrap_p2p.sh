#!/bin/bash

set -e

# iterate through each node and it open 4 P2P connections to its neigh neighbor.
for ((NODE_ID=0; NODE_ID<CLN_COUNT; NODE_ID++)); do
    peers=($(lncli --id="${NODE_ID}" listpeers 2>/dev/null | jq -r '.peers'))
    if [ ${#peers[@]} -ge 4 ]; then
        echo "Node ${NODE_ID} is connected to ${#peers[@]} peers"
        continue
    else
        for i in {1..4}; do
            NODE_PLUS_I=$((NODE_ID+i))
            NODE_MOD_COUNT=$((NODE_PLUS_I%4))

            if [ "$NODE_MOD_COUNT" != "$NODE_ID" ]; then
                # Now open a p2p connection
                NEXT_NODE_PUBKEY=$(lncli --id=$NODE_MOD_COUNT getinfo | jq -r '.id')
                lncli --id="$NODE_ID" connect "$NEXT_NODE_PUBKEY" "cln-$NODE_MOD_COUNT" 9735 > /dev/null
            fi
        done
    fi
done
