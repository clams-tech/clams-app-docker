#!/bin/bash

set -e

RUNE_TYPE=

# grab any modifications from the command line.
for i in "$@"; do
    case $i in
        --type=*)
            RUNE_TYPE="${i#*=}"
            shift
        ;;
        *)
        echo "Unexpected option: $1"
        exit 1
        ;;
    esac
done

if [ -z "$RUNE_TYPE" ]; then
    echo "ERROR: rune type must be specified."
    exit 1
fi

echo "Please enter the Clams rune command you copied from the app:  "
read -r SESSION_ID

source ./.env

if docker ps -a | grep -q clams-clightning; then
    COMMAND_TO_EXECUTE="docker exec -it -u $UID:$UID clams-clightning lightning-cli --network $BTC_CHAIN commando-rune restrictions='[[\"id=$SESSION_ID\"], [\"rate=60\"]]'"

    ADMIN_RUNE=$(eval "$COMMAND_TO_EXECUTE" | jq -r '.rune')
    echo "Rune: $ADMIN_RUNE"
else
    echo "ERROR: Cannot find the clightning container. Did you run it?"
    exit 1
fi
