#!/bin/bash

set -eu
cd "$(dirname "$0")"

# this script tears everything down that might be up. It does not destroy data.

source ./.env

cd ./backend/
if [ -f ./docker-compose.yml ]; then
    TIME_PER_CLN_NODE=4
    if docker stack ls --format "{{.Name}}" | grep -q clams-stack; then
        docker stack rm clams-stack && sleep $(($CLN_COUNT * $TIME_PER_CLN_NODE))
    fi
fi

cd ./nginx/
if [ -f ./docker-compose.yml ]; then
    docker compose down
    rm -rf ./nginx.conf
    rm docker-compose.yml
fi
cd ..

cd ..

# let's give docker time to tear everything down
# maybe multiply by CLN Count?


docker system prune -f

docker volume prune -f