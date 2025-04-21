#!/usr/bin/env bash

set -e

SCRIPT_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

. "$SCRIPT_PATH/_common.sh"

PLAYER_ID="${PLAYER_ID:-1}"
SEEK_SECONDS="${S:-30}"

read -r -d '' QUERY <<EOF || true
{
  "id": 1,
  "jsonrpc": "2.0",
  "method": "Player.Seek",
  "params": {
    "playerid": $PLAYER_ID,
    "value": {
      "seconds": $SEEK_SECONDS
    }
  }
}
EOF

query_json "$QUERY"
