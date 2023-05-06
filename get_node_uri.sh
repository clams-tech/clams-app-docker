#!/bin/bash

set -e
cd "$(dirname "$0")"

. ./defaults.env
. ./load_env.sh

NODE_ID=0

# grab any modifications from the command line.
for i in "$@"; do
    case $i in
        --id=*)
            NODE_ID="${i#*=}"
            shift
        ;;
        *)
        ;;
    esac
done

PORT=$((STARTING_WEBSOCKET_PORT+NODE_ID))

NODE_PUBKEY=$(bash -c "./lightning-cli.sh --id=$NODE_ID getinfo" | jq -r '.id')
echo "$NODE_PUBKEY@$DOMAIN_NAME:$PORT"
