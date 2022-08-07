#!/usr/bin/env bash

set -e

mkdir -p $HOME/Desktop

TIME=$(date '+%Y-%m-%d_%H-%M-%S-%3N')
TMP_FILE="$HOME/Desktop/screenshot.$TIME.png"

import -silent "$TMP_FILE"

echo "$TMP_FILE created"
