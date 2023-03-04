#!/bin/bash

set -ex
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

if ! dig +short "$CLAMS_FQDN" | grep -q "$BIND_ADDR"; then
    if [ "$BIND_ADDR" != "0.0.0.0" ]; then
        echo "ERROR: '$CLAMS_FQDN' does not resolve to '$BIND_ADDR'. Check your settings."
        exit 1
    fi
fi

if [ "$ENABLE_TLS" = false ] && [ "$BIND_ADDR" != "127.0.0.1" ]; then
    echo "ERROR: when TLS is disabled, BIND_ADDR MUST be 127.0.0.1."
    echo "       doing otherwise could lead to insecure deployments."
    exit 1
fi

if [ "$ENABLE_TLS" = true ] && [ "$DEPLOY_LN_WS_PROXY" = true ] && [ "$LN_WS_PROXY_HOSTNAME" = localhost ]; then
    echo "ERROR: You MUST set LN_WS_PROXY_HOSTNAME to a hostname resolveable in the DNS."
    exit 1
fi

if [ "$BTC_CHAIN" != regtest ] && [ "$BTC_CHAIN" != testnet ] && [ "$BTC_CHAIN" != mainnet ]; then
    echo "ERROR: BTC_CHAIN must be either 'regtest', 'testnet', or 'mainnet'."
    exit 1
fi

# Error out if the user selects mainnet.
if [ "$BTC_CHAIN" = mainnet ]; then
    echo "ERROR: Bitcoin mainnet is not supported at this time."
    exit 1
fi

export CLAMS_FQDN="$CLAMS_FQDN"
export BIND_ADDR="$BIND_ADDR"
export BTC_CHAIN="$BTC_CHAIN"
export CLIGHTNING_WEBSOCKET_EXTERNAL_PORT="$CLIGHTNING_WEBSOCKET_EXTERNAL_PORT"
export DEPLOY_BTC_BACKEND="$DEPLOY_BTC_BACKEND"
export ENABLE_TLS="$ENABLE_TLS"
export LIGHTNING_P2P_EXTERNAL_POR="$CLIGHTNING_P2P_EXTERNAL_PORT"
export DEPLOY_LN_WS_PROXY="$DEPLOY_LN_WS_PROXY"
export LN_WS_PROXY_HOSTNAME="$LN_WS_PROXY_HOSTNAME"
export BROWSER_APP_EXTERNAL_PORT="$BROWSER_APP_EXTERNAL_PORT"
export DEPLOY_BROWSER_APP="$DEPLOY_BROWSER_APP"
export BROWSER_APP_GIT_REPO_URL="$BROWSER_APP_GIT_REPO_URL"
export BROWSER_APP_GIT_TAG="$BROWSER_APP_GIT_TAG"
export LN_WS_PROXY_GIT_REPO_URL="$LN_WS_PROXY_GIT_REPO_URL"
export LN_WS_PROXY_GIT_TAG="$LN_WS_PROXY_GIT_TAG"

if [ "$DEPLOY_BTC_BACKEND" = true ]; then
    # exposes core lightning
    BTC_CHAIN="$BTC_CHAIN" ./backend/run.sh
fi

# run the front-end script.
./frontend/run.sh

if [ "$DEPLOY_BROWSER_APP" = true ]; then
    # the entrypoint is http in all cases; if ENABLE_TLS=true, then we rely on the 302 redirect to https.
    echo "The Clams Browser App is available at http://${CLAMS_FQDN}:${BROWSER_APP_EXTERNAL_PORT}"
fi


if [ "$DEPLOY_BTC_BACKEND" = true ]; then
    # now let's output the core lightning node URI so the user doesn't need to fetch that manually.

    echo "Your core-lightning websocket \"Direct Connection (ws)\" URI is: "
    ./get_node_uri.sh
    

    SESSION_ID=
    read -r -e -p "Paste the Clams session ID and press enter:  " SESSION_ID

    # check dependencies
    for RUNE_TYPE in admin read-only clams; do
        RUNE=$(bash -c "./get_rune.sh --type=$RUNE_TYPE --session-id=$SESSION_ID")
        echo "$RUNE_TYPE:  $RUNE"
    done

fi

if [ "$DEPLOY_BACKEND" = true ]; then
    PROTOCOL=ws
    if [ "$ENABLE_TLS" = true ]; then
        PROTOCOL=wss
    fi
    # the entrypoint is http in all cases; if ENABLE_TLS=true, then we rely on the 302 redirect to https.
    echo "Your lightning websocket enpoint can be found at '$PROTOCOL://$BIND_ADDR:$CLIGHTNING_WEBSOCKET_EXTERNAL_PORT'."

fi

if [ "$DEPLOY_LN_WS_PROXY" = true ]; then
    PROTOCOL=ws
    if [ "$ENABLE_TLS" = true ]; then
        PROTOCOL=wss
    fi

    # the entrypoint is http in all cases; if ENABLE_TLS=true, then we rely on the 302 redirect to https.
    echo "Your wss endpoint can be found at: '$PROTOCOL://$LN_WS_PROXY_HOSTNAME'."
fi
