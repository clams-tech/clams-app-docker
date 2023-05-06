#!/bin/bash

set -eu
cd "$(dirname "$0")"

. ./defaults.env
. ./load_env.sh

bash -c "./down.sh"

# ANSWER=n
# read -r -e -p "Would you like to delete (non cert) volumes?" ANSWER
# if [ "$ANSWER" = y ]; then
#     # check dependencies
#     for VOLUME in bitcoind clightning clams-browser-app; do
#         if docker volume list | grep -q "$VOLUME"; then
#             docker volume rm "$VOLUME" > /dev/null 2>&1
#         fi
#     done

#     # clear dangling volumes
#     for VOLUME in $(docker volume ls -q --filter dangling=true); do
#         if [ "$VOLUME" != clams-certs ]; then
#             docker volume rm "$VOLUME" > /dev/null 2>&1
#         fi
#     done


# TODO DELETE VOLUMES
# for CHAIN in signet testnet mainnet; do
#     VOLUME_NAME="bitcoin-${CHAIN}"
#     if ! docker volume list --format csv | grep -q "$VOLUME_NAME"; then
#         docker volume create "$VOLUME_NAME"
#     fi
# done

# fi


# ANSWER=n
# read -r -e -p "Would you like to delete the certificate store? " ANSWER
# if [ "$ANSWER" = y ]; then
#     if docker volume list | grep -q "clams-certs"; then
#         docker volume rm "clams-certs" > /dev/null 2>&1
#     fi
# fi


bash -c "./up.sh"