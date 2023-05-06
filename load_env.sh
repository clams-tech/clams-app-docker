#!/bin/bash

set -e
cd "$(dirname "$0")"

# read in ./active_env then source the file if it exists. export variables.
ACTIVE_ENV=$(cat ./active_env | head -n1 | awk '{print $1;}')

ENV_FILE="./environments/$ACTIVE_ENV"

if [ ! -f "$ENV_FILE" ]; then
    echo "ERROR: the env file does not exist. Check ./active_env and ensure the env file exists in ./environments/"
    exit 1
fi

source "$ENV_FILE"

export DOCKER_HOST="$DOCKER_HOST"
export DOMAIN_NAME="$DOMAIN_NAME"
export ENABLE_TLS="$ENABLE_TLS"