#!/bin/bash

set -ex
cd "$(dirname "$0")"

. ./defaults.env

ENV_FILE_PATH=
NODE_ID=0
PORT=9736

# grab any modifications from the command line.
for i in "$@"; do
    case $i in
        --env-file-path=*)
            ENV_FILE_PATH="${i#*=}"
            shift
        ;;
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

# ensure ENV_FILE_PATH is set and exists.
if [ -n "$ENV_FILE_PATH" ] && [ ! -f "$ENV_FILE_PATH" ]; then
    echo "ERROR: ENV_FILE_PATH does not exist."
    exit 1
fi

source "$ENV_FILE_PATH"

NODE_PUBKEY=$(bash -c "./lightning-cli.sh --id=$NODE_ID getinfo" | jq -r '.id')
echo "$NODE_PUBKEY@$DOMAIN_NAME:$PORT"
