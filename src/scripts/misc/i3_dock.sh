#!/usr/bin/env bash

set -euo pipefail

function run_loop() {
  while true; do
    local ACTIVE_WINDOW="$(xdotool getactivewindow)"
    local GEOMERY="$(xdotool getwindowgeometry $ACTIVE_WINDOW)"
    local STARTING_Y="$(echo "$GEOMERY" | grep Position | sed 's|.*Position:.*,\([0-9]*\) .*|\1|')"
    local HEIGHT="$(echo "$GEOMERY" | grep Geometry | sed 's|^.*x||')"
    local MOUSE_Y=$(xdotool getmouselocation --shell | awk -F "=" '/Y/{print $2}')
    local MAX_DIFF="40"
    local DISTANCE_TO_BOTTOM=$((HEIGHT - MOUSE_Y + STARTING_Y))

    # # `tail -f /tmp/i3_dock.log`
    # echo "HEIGHT: $HEIGHT" >>/tmp/i3_dock.log
    # echo "MOUSE_Y: $MOUSE_Y" >>/tmp/i3_dock.log
    # echo "DELTA: $DELTA" >>/tmp/i3_dock.log
    # echo "" >>/tmp/i3_dock.log

    if [ $DISTANCE_TO_BOTTOM -gt $MAX_DIFF ]; then
      i3-msg bar mode hide >/dev/null 2>&1
    else
      i3-msg bar mode dock >/dev/null 2>&1
    fi

    sleep 1
  done
}

run_loop
