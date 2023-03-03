#!/bin/bash

set -e
cd "$(dirname "$0")"

# this script tears everything down that might be up, then destroys the data.

cd ./backend/
docker compose down
cd ..

cd browser-app/
docker compose down
cd ..

cd ln-ws-proxy/
docker compose down
cd ..

docker system prune -f
