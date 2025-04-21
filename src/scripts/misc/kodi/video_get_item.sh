#!/usr/bin/env bash

set -e

SCRIPT_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

. "$SCRIPT_PATH/_common.sh"

PLAYER_ID=${PLAYER_ID:-1}

read -r -d '' QUERY <<EOF || true
{
  "id": "VideoGetItem",
  "jsonrpc": "2.0",
  "method": "Player.GetItem",
  "params": {
    "playerid": $PLAYER_ID,
    "properties": [
      "title",
      "album",
      "artist",
      "season",
      "episode",
      "duration",
      "showtitle",
      "tvshowid",
      "thumbnail",
      "file",
      "fanart",
      "streamdetails"
    ]
  }
}
EOF

query_json "$QUERY"
