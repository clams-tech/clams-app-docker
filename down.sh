#!/bin/bash

set -eu
cd "$(dirname "$0")"

# this script tears everything down that might be up. It does not destroy data.

source ./defaults.env
source ./load_env.sh

PURGE=false

# grab any modifications from the command line.
for i in "$@"; do
    case $i in
        --purge)
            PURGE=true
            shift
        ;;
        --purge=*)
            PURGE="${i#*=}"
            shift
        ;;
        *)
        ;;
    esac
done

cd ./roygbiv/

if [ -f ./docker-compose.yml ]; then
    TIME_PER_CLN_NODE=4
    if docker stack ls --format "{{.Name}}" | grep -q roygbiv-stack; then
        docker stack rm roygbiv-stack && sleep $((CLN_COUNT * TIME_PER_CLN_NODE))
        sleep 5
    fi
fi

cd ..

# let's give docker time to tear everything down
# maybe multiply by CLN Count?


docker system prune -f

docker volume prune -f

sleep 2

if [ "$PURGE" = true ]; then
    # check dependencies
    VOLUME="bitcoin-$BTC_CHAIN"
    if docker volume list | grep -q "$VOLUME"; then
        docker volume rm "$VOLUME" > /dev/null 2>&1
    fi

fi
