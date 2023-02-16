#!/bin/bash

set -eu
cd "$(dirname "$0")"

# this script destroys everything -- including output files -- then brings everything back up.

./destroy.sh

rm -rf ./browser-app/www-root
rm -rf ./backend/volumes

docker volume rm $(docker volume ls -q --filter dangling=true) > /dev/null 2>&1 || true
