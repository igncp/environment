#!/usr/bin/env bash

set -e

DEVICE=$(adb devices | grep 'device$' | awk '{ print $1; }')

if [ -z "$DEVICE" ]; then
  echo "設備遺失"
  exit 1
fi

adb -s $DEVICE shell input text "$1"

echo "選擇密碼輸入並按任何鍵"
read -n 1 -s

adb -s $DEVICE shell input text "$2"
