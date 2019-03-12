#!/usr/bin/env bash

# You can download the latest Ubuntu version from: https://developer.android.com/studio#downloads
# And place it in this directory (zip files will be ignored)

set -e

docker run \
  -v "$(pwd):/project:ro" \
  -v="$HOME/.Xauthority:/root/.Xauthority:rw" \
  --net=host \
  --env="DISPLAY" \
  -it \
  --name android-studio \
  android-studio \
  /bin/bash
