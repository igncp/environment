#!/bin/bash

set -e

echo "建立緊虛擬視窗..."
sleep 5

while true; do
  FILTER="."
  if [ -f /home/igncp/VirtualWindow/filter.txt ]; then
    FILTER="$(cat /home/igncp/VirtualWindow/filter.txt)"
  fi
  FILE_CHOSEN="$(cat /home/igncp/VirtualWindow/list.txt | grep "$FILTER" | shuf -n 1)"
  FILE_NAME="$(echo "$FILE_CHOSEN" | awk '{ print $1; }')"
  FILE_PATH="/home/igncp/VirtualWindow/$FILE_NAME"

  BEFORE=$(date +%s)

  echo "打開緊虛擬窗口檔案 $FILE_PATH"

  DISPLAY=:0 /usr/bin/vlc -f \
    --play-and-exit --audio-track 1 "$FILE_PATH" >/dev/null 2>&1

  AFTER=$(date +%s)

  if [ "$((AFTER - BEFORE))" -lt 10 ]; then
    echo "睇落條片播唔到，退出緊"
    exit 1
  fi
done
