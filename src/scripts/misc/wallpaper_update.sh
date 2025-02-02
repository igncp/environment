#!/usr/bin/env bash

set -e

if [ -d ~/.config/variety/Downloaded ]; then
  IMAGE_PATH="$(find ~/.config/variety/Downloaded -type f -name *.jpg | shuf -n 1)"
else
  exit 1
fi

if type hyprctl &>/dev/null; then
  hyprctl hyprpaper unload all >/dev/null
  hyprctl hyprpaper preload "$IMAGE_PATH" >/dev/null
  hyprctl hyprpaper wallpaper ,"$IMAGE_PATH" >/dev/null
elif type pcmanfm &>/dev/null; then
  pcmanfm -w "$IMAGE_PATH"
elif type feh &>/dev/null; then
  feh --bg-fill "$IMAGE_PATH"
else
  exit 1
fi

echo "形象: $IMAGE_PATH"
