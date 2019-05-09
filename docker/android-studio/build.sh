#!/usr/bin/env bash

# Instructions: Need to download both Java JDK and Android Studio and place
# them in this directory

# - The Android Studio (IDE): `android-studio.tar.gz`
# https://developer.android.com/studio#downloads

# Once finished and inside the container, run:
# ./android-studio/bin/studio.sh
# # choose custom installation
# # choose the location `/home/ubuntu/android-sdk` as the location path
# # ~/android-studio should not be removed

set -e

sudo docker build \
  -t android-studio \
  .
