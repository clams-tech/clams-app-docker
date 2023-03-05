#!/bin/bash

set -eu
cd "$(dirname "$0")"

# this script destroys everything -- including output files -- then brings everything back up.
. ./defaults.env

. ./.env

./down.sh

ANSWER=n
read -r -e -p "Would you like to delete (non cert) volumes?" ANSWER
if [ "$ANSWER" = y ]; then
    # check dependencies
    for VOLUME in bitcoind clightning www-root; do
        if docker volume list | grep -q "$VOLUME"; then
            docker volume rm "$VOLUME" > /dev/null 2>&1
        fi
    done

    # clear dangling volumes
    for VOLUME in $(docker volume ls -q --filter dangling=true); do
        if [ "$VOLUME" != clams-certs ]; then
            docker volume rm "$VOLUME" > /dev/null 2>&1
        fi
    done
fi


ANSWER=n
read -r -e -p "Would you like to delete the certificate store? " ANSWER
if [ "$ANSWER" = y ]; then
    if docker volume list | grep -q "clams-certs"; then
        docker volume rm "clams-certs" > /dev/null 2>&1
    fi
fi


docker system prune -f