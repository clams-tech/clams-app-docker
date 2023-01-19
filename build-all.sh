#!/bin/bash

set -ex
cd "$(dirname "$0")"

./browser-app/build.sh

./ln-ws-proxy/build.sh
