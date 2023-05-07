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


# let's delete all volumes EXCEPT roygbiv-certs
if [ "$PURGE" = true ]; then

    # get a list of all the volumes
    VOLUMES=$(docker volume list -q)

    # Iterate over each value in the list
    for VOLUME in $VOLUMES; do
        if ! echo "$VOLUME" | grep -q "roygbiv-certs"; then
            docker volume rm "$VOLUME"
        fi
    done

fi
