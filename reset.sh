#!/bin/bash

set -eu
cd "$(dirname "$0")"

PURGE=false

# grab any modifications from the command line.
for i in "$@"; do
    case $i in
        --purge)
            PURGE=true
            shift
        ;;
        *)
        ;;
    esac
done

. ./defaults.env
. ./load_env.sh

bash -c "./down.sh"

if [ "$PURGE" = true ]; then
    # check dependencies
    for CHAIN in regtest signet testnet mainnet; do
        VOLUME="bitcoin-$CHAIN"
        if docker volume list | grep -q "$VOLUME"; then
            docker volume rm "$VOLUME" > /dev/null 2>&1
        fi
    done

    # # clear dangling volumes
    # for VOLUME in $(docker volume ls -q --filter dangling=true); do
    #     if [ "$VOLUME" != roygbiv-certs ]; then
    #         docker volume rm "$VOLUME" > /dev/null 2>&1
    #     fi
    # done

fi

bash -c "./up.sh"