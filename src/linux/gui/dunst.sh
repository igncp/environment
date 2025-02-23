#!/usr/bin/env bash

set -e

setup_gui_dunst() {
  if ! type dunst >/dev/null 2>&1; then
    return
  fi

  if [ ! -f ~/.config/dunst/dunstrc ]; then
    mkdir -p ~/.config/dunst
    (cd ~ &&
      rm -rf dunst &&
      git clone https://github.com/dunst-project/dunst.git)
    (mkdir -p ~/.config/dunst &&
      cp ~/dunst/dunstrc ~/.config/dunst/ &&
      rm -rf ~/dunst)
  fi

  sed -i 's| history =|#history =|' ~/.config/dunst/dunstrc
  sed -i 's|max_icon_size =.*|max_icon_size = 32|' ~/.config/dunst/dunstrc
  sed -i 's|font = .*$|font = Monospace 12|' ~/.config/dunst/dunstrc
  sed -i 's|geometry = .*$|geometry = "500x5-30+20"|' ~/.config/dunst/dunstrc
}
