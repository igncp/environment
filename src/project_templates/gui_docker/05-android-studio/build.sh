#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

cd "$SCRIPT_DIR"

docker build \
  --build-arg USER=igncp \
  --progress=plain \
  -t gui-test-android-studio \
  .
