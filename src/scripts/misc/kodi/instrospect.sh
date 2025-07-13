#!/usr/bin/env bash

set -euo pipefail

SCRIPT_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

. "$SCRIPT_PATH/_common.sh"

read -r -d '' QUERY <<EOF || true
{
  "id": 1,
  "jsonrpc": "2.0",
  "method": "Player.GetActivePlayers"
}
EOF

query_json "$QUERY"
