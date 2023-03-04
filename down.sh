#!/bin/bash

set -eu
cd "$(dirname "$0")"

# this script tears everything down that might be up. It does not destroy data.


cd ./frontend/
if [ -f ./docker-compose.yml ]; then
    docker compose down
    rm -rf ./nginx.conf
    rm docker-compose.yml
fi
cd ..


cd ./backend/
if [ -f ./docker-compose.yml ]; then
    docker compose down
fi
cd ..
