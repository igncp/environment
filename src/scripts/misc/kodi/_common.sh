#!/usr/bin/env bash

query_json() {
  DATA="$1"
  curl \
    -f \
    -s \
    -H 'Content-Type: application/json' \
    -d "$DATA" \
    http://localhost:8080/jsonrpc | jq -S
}
