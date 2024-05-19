#!/usr/bin/env bash

set -e

DEVICE=$(adb devices | grep 'device$' | awk '{ print $1; }')

if [ -z "$DEVICE" ]; then
  echo "設備遺失"
  exit 1
fi

if [ -n "$1" ]; then
  echo "錄影完畢"
  adb -s "$DEVICE" pull /sdcard/video.mp4 /tmp/

  adb -s "$DEVICE" shell rm /sdcard/video.mp4

  DATE=$(date +"%Y-%m-%d_%H-%M-%S")

  mkdir -p ~/Desktop

  mv /tmp/video.mp4 ~/Desktop/android_video_$DATE.mp4
  cp ~/Desktop/android_video_$DATE.mp4 ~/Desktop/android_video_latest.mp4

  echo "影片儲存至 ~/Desktop/android_video_$DATE.mp4 和 ~/Desktop/android_video_latest.mp4"

  exit 0
fi

echo "錄製影片。 按 Control-c 停止錄影"

adb -s "$DEVICE" shell screenrecord /sdcard/video.mp4
