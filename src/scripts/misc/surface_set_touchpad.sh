#!/usr/bin/env bash

set -e

# 1: 停用, 0: 啟用
STATUS="${1:-1}"

DEVICE_PATH="$(cat /proc/bus/input/devices |
  grep 'Microsoft Surface Keyboard Touchpad' -A2 |
  grep Sysfs |
  grep -o '/devices.*')"

sudo bash -c "echo $STATUS > /sys$DEVICE_PATH/inhibited"
