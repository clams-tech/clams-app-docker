#!/bin/bash

set -ex
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
if [ ! -f "$ENV_FILE_PATH" ]; then
    echo "ERROR: ENV_FILE_PATH does not exist."
fi

source "$ENV_FILE_PATH"

NODE_ID=0
PORT=9736

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
        *)
        ;;
    esac
done


NODE_PUBKEY=$(bash -c "./lightning-cli.sh --id=$NODE_ID getinfo" | jq -r '.id')
echo "$NODE_PUBKEY@$DOMAIN_NAME:$PORT"
