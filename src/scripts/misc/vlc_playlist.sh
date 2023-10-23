#!/usr/bin/env bash

set -e

# This script is intended to play a series of videos remotely, for example from
# a SSH session. It allows more flexibility than a common playlist, like
# automating the selection of the audio track number or the start time

# Update:
# - PATH_TO_FILE
# - Parameters passed to the `vlc` command (for example the subtitles delay)
#   - The first audio track is `0`
# - Zeros padded when using `printf` to generate the new number

FILE_NUM="012"

BEFORE=$(date +%s)

DISPLAY=:0 vlc -f --start-time=120 \
  --play-and-exit --audio-track 1 --sub-delay 20 \
  /PATH_TO_FILE/$FILE_NUM.mkv

AFTER=$(date +%s)

if [ "$((AFTER - BEFORE))" -lt 10 ]; then
  echo "It looks like the video couldn't be played, exiting"
  exit 1
fi

SCRIPT_PATH="$(cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P)/start.sh"

FILE_NUM_N=$((10#$FILE_NUM))
NEW_NUM_N=$((FILE_NUM_N+1))
NEW_NUM=$(printf '%03d\n' $NEW_NUM_N)

sed -i 's|^FILE_NUM=.*|FILE_NUM="'$NEW_NUM'"|' "$SCRIPT_PATH"

echo "Next episode $NEW_NUM prepared"

sh "$SCRIPT_PATH"
