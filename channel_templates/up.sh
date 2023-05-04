#!/bin/bash

until docker ps | grep -q bitcoind; do
    sleep 0.1;
done;

alias bitcoin-cli="bash -c ../bitcoin-cli.sh"
