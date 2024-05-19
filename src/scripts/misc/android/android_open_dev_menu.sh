#!/usr/bin/env bash

set -e

DEVICE=$(adb devices | grep 'device$' | awk '{ print $1; }')

if [ -z "$DEVICE" ]; then
  echo "設備遺失"
  exit 1
fi

adb -s $DEVICE shell input keyevent 82
