#!/usr/bin/env bash

# You can run this within the docker container

set -e

cd /home/ubuntu

if test -z "$(find . -maxdepth 1 -name 'android-studi*' -print -quit)"; then
  cp /project/*.zip .
fi

if test -n "$(find . -maxdepth 1 -name 'android-studi*.zip' -print -quit)"; then
  unzip ./android*
fi

rm -rf ./*.zip
