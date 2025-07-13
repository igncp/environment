#!/usr/bin/env bash

set -euo pipefail

. src/linux/gui/virtualbox.sh

provision_setup_linux_gui_apps() {
  TERMINATOR_CONFIG_PATH="$HOME/.config/terminator/config"
  if type terminator >/dev/null 2>&1 || [ -f "$TERMINATOR_CONFIG_PATH" ]; then
    mkdir -p ~/.config/terminator/
    cp ~/development/environment/src/config-files/terminator-config "$TERMINATOR_CONFIG_PATH"
  fi

  if type alacritty >/dev/null 2>&1; then
    mkdir -p ~/.config/alacritty
    cp ~/development/environment/src/config-files/alacritty.yml ~/.config/alacritty/alacritty.yml
    # alacritty 可以即時重新載入配置，有時最好先直接更改

    if [ "$ENVIRONMENT_THEME" != "light" ]; then
      sed -i "s|'light'|'dark'|" ~/.config/alacritty/alacritty.yml
      sed -i 's|background: .*|background: "#404040"|' ~/.config/alacritty/alacritty.yml
      sed -i 's|blue: .*|blue: "#a6bcff"|' ~/.config/alacritty/alacritty.yml
      sed -i 's|cyan: .*|cyan: "#a8f1ff"|' ~/.config/alacritty/alacritty.yml
      sed -i 's|foreground: .*|foreground: "#ffffff"|' ~/.config/alacritty/alacritty.yml
      sed -i 's|green: .*|green: "#bdffcd"|' ~/.config/alacritty/alacritty.yml
      sed -i 's|magenta: .*|magenta: "#ffcff9"|' ~/.config/alacritty/alacritty.yml
      sed -i 's|red: .*|red: "#ffc7d3"|' ~/.config/alacritty/alacritty.yml
      sed -i 's|yellow: .*|yellow: "#feffc7"|' ~/.config/alacritty/alacritty.yml
    fi
  fi

  provision_gui_virtualbox
}
