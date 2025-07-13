#!/usr/bin/env bash

set -euo pipefail

DEVICE=$(adb devices | grep 'device$' | awk '{ print $1; }')

if [ -z "$DEVICE" ]; then
  echo "設備遺失"
  exit 1
fi

DATE=$(date +"%Y-%m-%d_%H-%M-%S")

adb -s $DEVICE exec-out screencap -p >~/Desktop/android_screenshot_latest.png

mkdir -p ~/Desktop
cp ~/Desktop/screenshot_latest.png ~/Desktop/android_screenshot_$DATE.png

echo "螢幕截圖儲存到 ~/Desktop/android_screenshot_$DATE.png 和 ~/Desktop/screenshot_latest.png"
