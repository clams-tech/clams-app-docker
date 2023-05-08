#!/bin/bash

set -eu
cd "$(dirname "$0")"

. ./defaults.env
. ./load_env.sh

PURGE=false

# grab any modifications from the command line.
for i in "$@"; do
    case $i in
        --purge)
            PURGE=true
            shift
        ;;
        *)
        ;;
    esac
done

bash -c "./down.sh --purge=$PURGE"

sleep 10

bash -c "./up.sh"