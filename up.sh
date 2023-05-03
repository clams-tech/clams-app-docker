#!/bin/bash

set -e
cd "$(dirname "$0")"

# This script runs the whole Clams stack as determined by the various ./.env files


# check dependencies
for cmd in jq docker dig; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "This script requires \"${cmd}\" to be installed.."
        exit 1
    fi
done


. ./defaults.env

. ./.env

OUTPUT_NGINX_FRAGMENTS=true

# grab any modifications from the command line.
for i in "$@"; do
    case $i in
        --no-nginx-fragments)
            OUTPUT_NGINX_FRAGMENTS=false
            shift
        ;;
        *)
        echo "Unexpected option: $1"
        exit 1
        ;;
    esac
done

export OUTPUT_NGINX_FRAGMENTS="$OUTPUT_NGINX_FRAGMENTS"

if [ "$ENABLE_TLS" = true ] && [ "$CLAMS_FQDN" = localhost ]; then
    echo "ERROR: You can't use TLS with with a CLAMS_FQDN of 'localhost'. Use something that's resolveable by in DNS."
    exit 1
fi

echo "INFO: You are targeting '$BTC_CHAIN'"

if [ "$ENABLE_TLS" = true ] && [ "$DEPLOY_LN_WS_PROXY" = true ] && [ "$LN_WS_PROXY_HOSTNAME" = localhost ]; then
    echo "ERROR: You MUST set LN_WS_PROXY_HOSTNAME to a hostname resolveable in the DNS."
    exit 1
fi

if [ "$BTC_CHAIN" != regtest ] && [ "$BTC_CHAIN" != signet ] && [ "$BTC_CHAIN" != testnet ] && [ "$BTC_CHAIN" != mainnet ]; then
    echo "ERROR: BTC_CHAIN must be either 'regtest', 'signet', 'testnet', or 'mainnet'."
    exit 1
fi

export CLAMS_FQDN="$CLAMS_FQDN"
export BTC_CHAIN="$BTC_CHAIN"
export CLIGHTNING_WEBSOCKET_EXTERNAL_PORT="$CLIGHTNING_WEBSOCKET_EXTERNAL_PORT"

export ENABLE_TLS="$ENABLE_TLS"
export LIGHTNING_P2P_EXTERNAL_PORT="$CLIGHTNING_P2P_EXTERNAL_PORT"
export DEPLOY_LN_WS_PROXY="$DEPLOY_LN_WS_PROXY"
export LN_WS_PROXY_HOSTNAME="$LN_WS_PROXY_HOSTNAME"
export BROWSER_APP_EXTERNAL_PORT="$BROWSER_APP_EXTERNAL_PORT"

export BROWSER_APP_GIT_REPO_URL="$BROWSER_APP_GIT_REPO_URL"
export BROWSER_APP_GIT_TAG="$BROWSER_APP_GIT_TAG"
export LN_WS_PROXY_GIT_REPO_URL="$LN_WS_PROXY_GIT_REPO_URL"
export LN_WS_PROXY_GIT_TAG="$LN_WS_PROXY_GIT_TAG"
export CLN_COUNT="$CLN_COUNT"


# exposes core lightning
BTC_CHAIN="$BTC_CHAIN" ./clams-stack/run.sh


# the entrypoint is http in all cases; if ENABLE_TLS=true, then we rely on the 302 redirect to https.
echo "The Clams Browser App is available at http://${CLAMS_FQDN}:${BROWSER_APP_EXTERNAL_PORT}"


for (( CLN_ID=0; CLN_ID<$CLN_COUNT; CLN_ID++ )); do
    CLN_ALIAS="cln-${CLN_ID}"
    CLN_WEBSOCKET_PORT=$(( $STARTING_WEBSOCKET_PORT+$CLN_ID ))
    # now let's output the core lightning node URI so the user doesn't need to fetch that manually.
    CLN_NODE_URI=$(bash -c ./get_node_uri.sh)
    echo "Your core-lightning websocket \"Direct Connection (ws)\" URI is: "
    ./get_node_uri.sh
done


SESSION_ID=
read -r -e -p "Paste the Clams session ID and press enter:  " SESSION_ID

# check dependencies
for RUNE_TYPE in admin read-only clams; do
    RUNE=$(bash -c "./get_rune.sh --type=$RUNE_TYPE --session-id=$SESSION_ID")
    echo "$RUNE_TYPE:  $RUNE"
done

PROTOCOL=ws
if [ "$ENABLE_TLS" = true ]; then
    PROTOCOL=wss
fi
# the entrypoint is http in all cases; if ENABLE_TLS=true, then we rely on the 302 redirect to https.
echo "Your lightning websocket endpoint can be found at '$PROTOCOL://${CLAMS_FQDN}:$CLIGHTNING_WEBSOCKET_EXTERNAL_PORT'."

if [ "$DEPLOY_LN_WS_PROXY" = true ]; then
    PROTOCOL=ws
    if [ "$ENABLE_TLS" = true ]; then
        PROTOCOL=wss
    fi

    # the entrypoint is http in all cases; if ENABLE_TLS=true, then we rely on the 302 redirect to https.
    echo "Your wss endpoint can be found at: '$PROTOCOL://$LN_WS_PROXY_HOSTNAME'."
fi
