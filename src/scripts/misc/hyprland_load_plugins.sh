#!/usr/bin/env bash

set -e

HYPR_EXPO="$(find /nix/store -maxdepth 1 | grep hyprexpo | grep -v '\.drv' || true)"

if [ -z "$HYPR_EXPO" ]; then
  echo "hyprland_load_plugins.sh: 未找到插件 hyprexpo" >&2
  exit 1
fi

hyprctl plugin load "$HYPR_EXPO"/lib/libhyprexpo.so || true
