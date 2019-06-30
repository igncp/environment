#!/usr/bin/env bash

set -e

clean_images() {
  EXTENSION=$1
  USED_DIR=${2:-/home/ubuntu/content}
  printf "looking recursively in: $USED_DIR\n"
  find "$USED_DIR" -type f -name "*.$EXTENSION" | xargs -I {} rm -rf {}
}

clean_images png $@
