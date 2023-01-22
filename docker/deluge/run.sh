#!/usr/bin/env bash

set -e

SCRIPT_PATH=$(dirname $(readlink -f $0))

cd $SCRIPT_PATH

docker compose up -d

echo "To be replaced with the script that will start the vpn"
exit 1
