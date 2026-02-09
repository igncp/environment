#!/usr/bin/env bash

set -e

if [ -f $HOME/.nix-profile/bin/env ]; then
  . $HOME/.nix-profile/etc/profile.d/nix.sh
fi

nixGL rofi -show combi \
  -font "hack 20" \
  -combi-modi drun,window,ssh \
  -theme-str 'window { height: 90%; }'
