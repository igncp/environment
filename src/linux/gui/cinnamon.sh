#!/usr/bin/env bash

set -euo pipefail

setup_gui_cinnamon() {
  if [ ! -f "$PROVISION_CONFIG"/gui-cinnamon ]; then
    return
  fi

  cat >>~/.shell_aliases <<'EOF'
CinnamonShortcutsDump() {
  dconf dump /org/cinnamon/desktop/keybindings/ > /tmp/dconf-settings.conf
  echo "將資料轉儲到 /tmp/dconf-settings.conf"
}

CinnamonShortcutsLoad() {
  dconf load /org/cinnamon/desktop/keybindings/ < /tmp/dconf-settings.conf
  echo "載入檔案 FOO /tmp/dconf-settings.conf"
}
EOF

  if [ ! -f ~/.check-files/cinnamon-gsettings ] && type gsettings >/dev/null 2>&1; then
    gsettings set org.cinnamon panels-autohide "['1:true']"

    mkdir -p ~/.check-files && touch ~/.check-files/cinnamon-gsettings
  fi

  if [ -d ~/.config/autostart/ ]; then
    cp src/config-files/cinnamon-wallpaper-update.desktop ~/.config/autostart
    cat ~/.config/autostart/cinnamon-wallpaper-update.desktop |
      sed "s|__HOME__|$HOME|" | sponge ~/.config/autostart/cinnamon-wallpaper-update.desktop
  fi
}
