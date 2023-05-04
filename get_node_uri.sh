#!/bin/bash

set -e
cd "$(dirname "$0")"

. ./defaults.env

ENV_FILE_PATH=$(pwd)/environments/local.env

# grab any modifications from the command line.
for i in "$@"; do
    case $i in
        --env-file-path=*)
            ENV_FILE_PATH="${i#*=}"
            shift
        ;;
        *)
        ;;
    esac
done

# source the 
if [ -f "$ENV_FILE_PATH" ]; then
    source "$ENV_FILE_PATH"
fi

NODE_ID=0
PORT=9736
DOMAIN_NAME=

# grab any modifications from the command line.
for i in "$@"; do
    case $i in
        --id=*)
            NODE_ID="${i#*=}"
            shift
        ;;
        --port=*)
            PORT="${i#*=}"
            shift
        ;;
        --domain-name=*)
            DOMAIN_NAME="${i#*=}"
            shift
        ;;
        *)
        ;;
    esac
done

if [ -z "$DOMAIN_NAME" ]; then
    echo "ERROR: you MUST set a DOMAIN_NAME"
    exit 1
fi

NODE_PUBKEY=$(bash -c "./lightning-cli.sh --id=$NODE_ID getinfo" | jq -r '.id')
echo "$NODE_PUBKEY@$DOMAIN_NAME:$PORT"
