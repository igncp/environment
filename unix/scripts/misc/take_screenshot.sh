#!/usr/bin/env bash

set -e

mkdir -p /home/igncp/Desktop

TIME=$(date '+%Y-%m-%d_%H-%M-%S-%3N')
TMP_FILE="/home/igncp/Desktop/screenshot.$TIME.png"

import "$TMP_FILE"

echo "$TMP_FILE created"
