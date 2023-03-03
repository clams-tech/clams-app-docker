#!/bin/bash

set -e
cd "$(dirname "$0")"

# This script runs the whole Clams stack as determined by the various ./.env files


# check dependencies
for cmd in jq docker; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "This script requires \"${cmd}\" to be installed.."
        exit 1
    fi
done


. ./.env

# Error out if the user selects mainnet.
if [ "$BTC_CHAIN" = mainnet ]; then
    echo "ERROR: This software does not support mainnet at this time."
    exit 1
fi

if [ "$DEPLOY_BTC_BACKEND" = true ]; then
    # exposes core lightning
    BTC_CHAIN="$BTC_CHAIN" ./backend/run.sh
fi

if [ "$DEPLOY_LN_WS_PROXY" = true ]; then
    # exposes at ln-ws-proxy 127.0.0.1:3000
    ./ln-ws-proxy/run.sh
fi

if [ "$DEPLOY_BROWSER_APP" = true ]; then
    ./browser-app/run.sh
fi

sleep 5

# now let's output the core lightning node URI so the user doesn't need to fetch that manually.
./get_node_uri.sh

bash -c "./get_rune.sh --type=admin"
