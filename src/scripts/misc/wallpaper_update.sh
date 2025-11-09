#!/usr/bin/env bash

set -euo pipefail

log() {
  local CONTENT="$(cat -)"
  logger -t wallpaper_update "$CONTENT"
}

echo "更新緊壁紙" | log

if [ -d ~/.config/variety/Downloaded ]; then
  IMAGE_PATH="$(find ~/.config/variety/Downloaded -type f -name *.jpg | shuf -n 1)"
  echo "$IMAGE_PATH" | log
else
  echo "喺入面搵唔到圖片 ~/.config/variety/Downloaded" | log
  exit 1
fi

if type hyprctl &>/dev/null && [ "${XDG_CURRENT_DESKTOP:-}" == "Hyprland" ]; then
  hyprctl hyprpaper unload all >/dev/null
  hyprctl hyprpaper preload "$IMAGE_PATH" >/dev/null
  hyprctl hyprpaper wallpaper ,"$IMAGE_PATH" >/dev/null
elif type pcmanfm &>/dev/null; then
  pcmanfm -w "$IMAGE_PATH" 2>&1 | log
elif type pcmanfm-qt &>/dev/null; then
  pcmanfm-qt --wallpaper-mode=center --set-wallpaper "$IMAGE_PATH" 2>&1 | log
elif type gsettings &>/dev/null && [ "$XDG_CURRENT_DESKTOP" == "MATE" ]; then
  gsettings set org.mate.background picture-filename "$IMAGE_PATH" 2>&1 | log
elif type feh &>/dev/null; then
  echo "Using feh" | log
  feh --bg-fill "$IMAGE_PATH" 2>&1
else
  exit 1
fi

echo "形象: $IMAGE_PATH" | log
