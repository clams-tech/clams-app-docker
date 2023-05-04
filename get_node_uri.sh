#!/bin/bash

set -e
cd "$(dirname "$0")"

. ./defaults.env
. ./.env

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

NODE_PUBKEY=$(bash -c "./lightning-cli.sh --id=$NODE_ID getinfo" | jq -r '.id')
echo "$NODE_PUBKEY@$DOMAIN_NAME:$CLIGHTNING_WEBSOCKET_EXTERNAL_PORT"
