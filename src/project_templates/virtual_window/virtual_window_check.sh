#!/usr/bin/env bash

# 呢個指令碼係由virtual-window-check.service 執行

set -e

SCRIPTPATH="$(
  cd -- "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)"

chmod ogu-wx "$SCRIPTPATH/virtual_window_check.sh"

if [ -z "$(ps aux | grep 'yt-dlp' | grep -v grep || true)" ]; then
  ufw enable
  ufw default deny outgoing
fi
