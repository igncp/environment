#!/usr/bin/env bash

. "$HOME/.nix-profile/etc/profile.d/nix.sh" || true

bash $HOME/development/environment/src/scripts/misc/i3_dock.sh &

start_if_not_running() {
  local PROCESS_NAME="$1"
  local COMMAND_TO_RUN="$2"

  if [ -z "$COMMAND_TO_RUN" ]; then
    COMMAND_TO_RUN="$PROCESS_NAME"
  fi

  if [ -z "$(ps aux | grep "$PROCESS_NAME" | grep -v grep || true)" ]; then
    eval "$COMMAND_TO_RUN" &
  fi
}

start_if_not_running pasystray
start_if_not_running nm-applet
start_if_not_running dunst
start_if_not_running ibus 'ibus start'

if type gsettings >/dev/null 2>&1; then
  gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
  gsettings set org.gnome.desktop.interface gtk-theme "adw-gtk3"
fi

bash $HOME/development/environment/src/scripts/misc/wallpaper_update.sh &
