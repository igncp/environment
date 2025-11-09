#!/usr/bin/env bash

bash $HOME/.scripts/gui_daemons.sh &
bash $HOME/development/environment/src/scripts/misc/i3_dock.sh &

if [ -z "$(ps aux | grep pasystray | grep -v grep || true)" ]; then
  bash -c "/run/current-system/sw/bin/pasystray || $HOME/.nix-profile/bin/pasystray || true" &
fi

bash $HOME/development/environment/src/scripts/misc/wallpaper_update.sh &
