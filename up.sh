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
. ./load_env.sh

if docker info | grep -q "Swarm: active"; then
    if docker stack list | grep -q "roygbiv-stack"; then
        echo "ERROR: the 'roygbiv-stack' is currently active. You may need to run ./down.sh or ./reset.sh first."
        exit 1
    fi
fi

if [ "$ENABLE_TLS" = true ] && [ "$DOMAIN_NAME" = localhost ]; then
    echo "ERROR: You can't use TLS with with a DOMAIN_NAME of 'localhost'. Use something that's resolveable by in DNS."
    exit 1
fi

echo "INFO: All commands are being applied using the following DOCKER_HOST string: $DOCKER_HOST"
echo "INFO: You are targeting '$BTC_CHAIN' using domain '$DOMAIN_NAME'."

if [ "$ENABLE_TLS" = true ] && [ "$LN_WS_PROXY_HOSTNAME" = localhost ]; then
    echo "ERROR: You MUST set LN_WS_PROXY_HOSTNAME to a hostname resolveable in the DNS."
    exit 1
fi

if [ "$BTC_CHAIN" != regtest ] && [ "$BTC_CHAIN" != signet ] && [ "$BTC_CHAIN" != testnet ] && [ "$BTC_CHAIN" != mainnet ]; then
    echo "ERROR: BTC_CHAIN must be either 'regtest', 'signet', 'testnet', or 'mainnet'."
    exit 1
fi

export DOCKER_HOST="$DOCKER_HOST"
export BTC_CHAIN="$BTC_CHAIN"
export CLIGHTNING_WEBSOCKET_EXTERNAL_PORT="$CLIGHTNING_WEBSOCKET_EXTERNAL_PORT"
export ENABLE_TLS="$ENABLE_TLS"
export LIGHTNING_P2P_EXTERNAL_PORT="$CLIGHTNING_P2P_EXTERNAL_PORT"
export LN_WS_PROXY_HOSTNAME="$LN_WS_PROXY_HOSTNAME"
export BROWSER_APP_EXTERNAL_PORT="$BROWSER_APP_EXTERNAL_PORT"
export BROWSER_APP_GIT_REPO_URL="$BROWSER_APP_GIT_REPO_URL"
export BROWSER_APP_GIT_TAG="$BROWSER_APP_GIT_TAG"
export LN_WS_PROXY_GIT_REPO_URL="$LN_WS_PROXY_GIT_REPO_URL"
export LN_WS_PROXY_GIT_TAG="$LN_WS_PROXY_GIT_TAG"
export CLN_COUNT="$CLN_COUNT"
export DEPLOY_CLAMS_BROWSER_APP="$DEPLOY_CLAMS_BROWSER_APP"
export DEPLOY_PRISM_BROWSER_APP="$DEPLOY_PRISM_BROWSER_APP"
export DOMAIN_NAME="$DOMAIN_NAME"
CLAMS_FQDN="clams.${DOMAIN_NAME}"
export CLAMS_FQDN="$CLAMS_FQDN"
export RPC_PATH="$RPC_PATH"
export STARTING_WEBSOCKET_PORT="$STARTING_WEBSOCKET_PORT"
export PRISM_APP_GIT_TAG="$PRISM_APP_GIT_TAG"
export PRISM_APP_GIT_REPO_URL="$PRISM_APP_GIT_REPO_URL"
PRISM_APP_IMAGE_TAG="${PRISM_APP_GIT_TAG: -5}"
PRISM_APP_IMAGE_NAME="prism-browser-app:$PRISM_APP_IMAGE_TAG"
export PRISM_APP_IMAGE_NAME="$PRISM_APP_IMAGE_NAME"


./roygbiv/run.sh

# the entrypoint is http in all cases; if ENABLE_TLS=true, then we rely on the 302 redirect to https.
echo "The prism-browser-app is available at http://${DOMAIN_NAME}:${BROWSER_APP_EXTERNAL_PORT}"

if [ "$DEPLOY_CLAMS_BROWSER_APP" = true ]; then
    echo "The prism-browser-app is available at http://${DOMAIN_NAME}:${BROWSER_APP_EXTERNAL_PORT}"
fi

# print out the CLN node URIs for the user.
for (( CLN_ID=0; CLN_ID<CLN_COUNT; CLN_ID++ )); do
    CLN_ALIAS="cln-${CLN_ID}"
    CLN_WEBSOCKET_PORT=$(( STARTING_WEBSOCKET_PORT+CLN_ID ))

    # now let's output the core lightning node URI so the user doesn't need to fetch that manually.
    CLN_NODE_URI=$(bash -c "./get_node_uri.sh --id=${CLN_ID} --port=${CLN_WEBSOCKET_PORT}")
    echo "Your core-lightning websocket \"Direct Connection (ws)\" for '$CLN_ALIAS' is: $CLN_NODE_URI"
    
    # RUNE=$(bash -c "./get_rune.sh --id=${CLN_ID} --port=${CLN_WEBSOCKET_PORT}")
    # echo "Your cln admin rune for ${CLN_ALIAS} is: $RUNE"
done


# ok, let's do the channel logic
./channel_templates/up.sh
